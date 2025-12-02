package com.com.xodos.filepicker;

import static android.provider.DocumentsContract.Document.MIME_TYPE_DIR;
import static android.system.OsConstants.S_IFLNK;
import static android.system.OsConstants.S_IFMT;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.ProviderInfo;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.CancellationSignal;
import android.os.ParcelFileDescriptor;
import android.provider.DocumentsContract;
import android.provider.DocumentsContract.Document;
import android.provider.DocumentsContract.Root;
import android.provider.DocumentsProvider;
import android.system.ErrnoException;
import android.system.Os;
import android.system.StructStat;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.List;
import java.util.Objects;

/**
 * XoDos DocumentsProvider - Works exactly like Termux MTFile provider
 */
public class XDocumentsProvider extends DocumentsProvider {
    private static final String[] DEFAULT_ROOT_PROJECTION = {
        Root.COLUMN_ROOT_ID,
        Root.COLUMN_MIME_TYPES,
        Root.COLUMN_FLAGS,
        Root.COLUMN_ICON,
        Root.COLUMN_TITLE,
        Root.COLUMN_SUMMARY,
        Root.COLUMN_DOCUMENT_ID,
        Root.COLUMN_AVAILABLE_BYTES
    };

    private static final String[] DEFAULT_DOCUMENT_PROJECTION = {
        Document.COLUMN_DOCUMENT_ID,
        Document.COLUMN_MIME_TYPE,
        Document.COLUMN_DISPLAY_NAME,
        Document.COLUMN_LAST_MODIFIED,
        Document.COLUMN_FLAGS,
        Document.COLUMN_SIZE,
        "mt_extras"
    };

    private String pkgName;
    private File dataDir;      // /data/data/com.xodos
    private File filesDir;     // /data/data/com.xodos/files

    /**
     * Delete files in directory or soft link
     */
    private static boolean deleteFileOrDirectory(File file) {
        if (file.isDirectory()) {
            // Check if it's a symlink
            boolean isSymlink = false;
            try {
                isSymlink = (Os.lstat(file.getPath()).st_mode & S_IFMT) == S_IFLNK;
            } catch (ErrnoException e) {
                e.printStackTrace();
            }

            File[] subFiles = file.listFiles();
            if (!isSymlink && subFiles != null) {
                for (File sub : subFiles) {
                    if (!deleteFileOrDirectory(sub)) {
                        return false;
                    }
                }
            }
        }
        return file.delete();
    }

    private static String getMimeType(File file) {
        if (file.isDirectory()) {
            return MIME_TYPE_DIR;
        }

        String name = file.getName();
        int lastDot = name.lastIndexOf('.');
        if (lastDot >= 0) {
            String extension = name.substring(lastDot + 1).toLowerCase();
            String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
            if (mime != null) return mime;
        }
        return "application/octet-stream";
    }

    @SuppressLint("SdCardPath")
    @Override
    public final void attachInfo(Context context, ProviderInfo info) {
        super.attachInfo(context, info);
        this.pkgName = Objects.requireNonNull(getContext()).getPackageName();
        this.dataDir = Objects.requireNonNull(context.getFilesDir().getParentFile());
        this.filesDir = context.getFilesDir();
    }

    /**
     * Get file object by documentId - This is the KEY function that creates the virtual mapping
     */
    private final File getFileForDocId(String documentId, boolean lsFileState) throws FileNotFoundException {
        // Document ID format: com.xodos/files/path/to/file
        // or: com.xodos/data/path/to/file
        
        if (!documentId.startsWith(this.pkgName)) {
            throw new FileNotFoundException(documentId.concat(" not found"));
        }

        // Get the part after package name
        String virtualPath = documentId.substring(this.pkgName.length());
        if (virtualPath.startsWith("/")) {
            virtualPath = virtualPath.substring(1);
        }
        
        // Root directory - return null to indicate virtual root
        if (virtualPath.isEmpty()) {
            return null;
        }
        
        // Split into virtual directory and rest of path
        String[] parts = virtualPath.split("/", 2);
        String virtualDir = parts[0];
        String restPath = parts.length > 1 ? parts[1] : "";

        File targetFile;
        
        // Map virtual directories to real paths - EXACTLY like Termux
        if (virtualDir.equals("files")) {
            // This maps to com.xodos/files
            targetFile = new File(this.filesDir, restPath);
        } else if (virtualDir.equals("data")) {
            // This maps to com.xodos (the entire data directory)
            targetFile = new File(this.dataDir, restPath);
        } else {
            throw new FileNotFoundException(documentId.concat(" not found"));
        }

        if (lsFileState && targetFile != null) {
            try {
                Os.lstat(targetFile.getPath());
            } catch (Exception unused) {
                throw new FileNotFoundException(documentId.concat(" not found"));
            }
        }
        return targetFile;
    }

    @Override
    public final Bundle call(String method, String arg, Bundle extras) {
        Bundle call = super.call(method, arg, extras);
        if (call != null) {
            return call;
        }

        if (!method.startsWith("mt:")) {
            return null;
        }

        Bundle customBundle = new Bundle();
        customBundle.putBoolean("result", false);
        try {
            Uri uri = extras.getParcelable("uri");
            if (uri == null) {
                return customBundle;
            }
            
            List<String> pathSegments = uri.getPathSegments();
            String documentId = pathSegments.size() >= 4 ? pathSegments.get(3) : pathSegments.get(1);
            
            switch (method) {
                case "mt:setPermissions": {
                    // Change file permissions (chmod)
                    File file = getFileForDocId(documentId, true);
                    if (file != null) {
                        int permissions = extras.getInt("permissions");
                        Os.chmod(file.getPath(), permissions);
                        customBundle.putBoolean("result", true);
                    }
                    return customBundle;
                }
                case "mt:createSymlink": {
                    // Create symbolic link
                    File file = getFileForDocId(documentId, false);
                    if (file != null) {
                        String targetPath = extras.getString("path");
                        Os.symlink(targetPath, file.getPath());
                        customBundle.putBoolean("result", true);
                    }
                    return customBundle;
                }
                case "mt:setLastModified": {
                    // Set file modification time
                    File file = getFileForDocId(documentId, true);
                    if (file != null) {
                        customBundle.putBoolean("result", file.setLastModified(extras.getLong("time")));
                    }
                    return customBundle;
                }
                case "mt:getPermissions": {
                    // Get current file permissions
                    File file = getFileForDocId(documentId, true);
                    if (file != null) {
                        try {
                            StructStat stat = Os.lstat(file.getPath());
                            customBundle.putBoolean("result", true);
                            customBundle.putInt("permissions", stat.st_mode & 0777); // Only permissions bits
                            customBundle.putInt("uid", stat.st_uid);
                            customBundle.putInt("gid", stat.st_gid);
                        } catch (ErrnoException e) {
                            customBundle.putString("message", e.getMessage());
                        }
                    }
                    return customBundle;
                }
                case "mt:setOwner": {
                    // Change file owner (chown)
                    File file = getFileForDocId(documentId, true);
                    if (file != null) {
                        try {
                            Os.chown(file.getPath(), extras.getInt("uid"), extras.getInt("gid"));
                            customBundle.putBoolean("result", true);
                        } catch (ErrnoException e) {
                            customBundle.putString("message", e.getMessage());
                        }
                    }
                    return customBundle;
                }
                default:
                    throw new RuntimeException("Unsupported method: ".concat(method));
            }
        } catch (Exception e) {
            customBundle.putBoolean("result", false);
            customBundle.putString("message", e.toString());
            return customBundle;
        }
    }

    @Override
    public final String createDocument(String parentDocumentId, String mimeType, String displayName) throws FileNotFoundException {
        File parentFile = getFileForDocId(parentDocumentId, true);
        if (parentFile != null) {
            File newFile = new File(parentFile, displayName);
            int noConflictId = 2;
            while (newFile.exists()) {
                newFile = new File(parentFile, displayName + " (" + noConflictId + ")");
                noConflictId++;
            }
            try {
                boolean succeeded = MIME_TYPE_DIR.equals(mimeType)
                    ? newFile.mkdir()
                    : newFile.createNewFile();

                if (succeeded) {
                    return parentDocumentId + "/" + newFile.getName();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        throw new FileNotFoundException("Failed to create document in " + parentDocumentId + " with name " + displayName);
    }

    /**
     * Add a representation of a file to a cursor
     */
    private void includeFile(MatrixCursor result, String docId, File file) throws FileNotFoundException {
        if (file == null) {
            file = getFileForDocId(docId, true);
        }

        // Root directory - show virtual root
        if (file == null) {
            Context ctx = getContext();
            String title = ctx == null ? "XoDos" : ctx.getApplicationInfo().loadLabel(getContext().getPackageManager()).toString();

            MatrixCursor.RowBuilder row = result.newRow();
            row.add(Document.COLUMN_DOCUMENT_ID, this.pkgName);
            row.add(Document.COLUMN_DISPLAY_NAME, title);
            row.add(Document.COLUMN_SIZE, 0);
            row.add(Document.COLUMN_MIME_TYPE, MIME_TYPE_DIR);
            row.add(Document.COLUMN_LAST_MODIFIED, 0);
            row.add(Document.COLUMN_FLAGS, 
                Document.FLAG_DIR_SUPPORTS_CREATE | 
                Document.FLAG_SUPPORTS_DELETE |
                Document.FLAG_SUPPORTS_RENAME |
                Document.FLAG_SUPPORTS_SETTINGS |
                Document.FLAG_DIR_PREFERS_LAST_MODIFIED);
            return;
        }

        int flags = 0;
        
        // Set flags based on file type and permissions
        if (file.isDirectory()) {
            flags |= Document.FLAG_DIR_SUPPORTS_CREATE |
                     Document.FLAG_DIR_PREFERS_LAST_MODIFIED;
        } else {
            if (file.canWrite()) {
                flags |= Document.FLAG_SUPPORTS_WRITE;
            }
        }

        // Always include these flags for full control
        flags |= Document.FLAG_SUPPORTS_SETTINGS |  // This enables permission management
                 Document.FLAG_SUPPORTS_COPY | 
                 Document.FLAG_SUPPORTS_MOVE |
                 Document.FLAG_SUPPORTS_DELETE |
                 Document.FLAG_SUPPORTS_RENAME;

        String displayName;
        String path = file.getPath();

        // For virtual directories, show friendly names
        if (path.equals(this.filesDir.getPath())) {
            displayName = "files";
        } else if (path.equals(this.dataDir.getPath())) {
            displayName = "data";
        } else {
            displayName = file.getName();
        }

        MatrixCursor.RowBuilder row = result.newRow();
        row.add(DocumentsContract.Document.COLUMN_DOCUMENT_ID, docId);
        row.add(DocumentsContract.Document.COLUMN_DISPLAY_NAME, displayName);
        row.add(DocumentsContract.Document.COLUMN_SIZE, file.length());
        row.add(DocumentsContract.Document.COLUMN_MIME_TYPE, getMimeType(file));
        row.add(DocumentsContract.Document.COLUMN_LAST_MODIFIED, file.lastModified());
        row.add(DocumentsContract.Document.COLUMN_FLAGS, flags);
        row.add("mt_path", file.getAbsolutePath());
        
        // Add extended file information (mode, uid, gid, symlink target)
        try {
            StructStat lstat = Os.lstat(path);
            StringBuilder sb = new StringBuilder()
                .append(lstat.st_mode)
                .append("|").append(lstat.st_uid)
                .append("|").append(lstat.st_gid);
            if ((lstat.st_mode & S_IFMT) == S_IFLNK) {
                sb.append("|").append(Os.readlink(path));
            }
            row.add("mt_extras", sb.toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public final void deleteDocument(String documentId) throws FileNotFoundException {
        File file = getFileForDocId(documentId, true);
        if (file == null || !deleteFileOrDirectory(file)) {
            throw new FileNotFoundException("Failed to delete document ".concat(documentId));
        }
    }

    @Override
    public final String getDocumentType(String documentId) throws FileNotFoundException {
        File file = getFileForDocId(documentId, true);
        return file == null ? MIME_TYPE_DIR : getMimeType(file);
    }

    @Override
    public final boolean isChildDocument(String parentDocumentId, String documentId) {
        return documentId.startsWith(parentDocumentId);
    }

    @Override
    public final String moveDocument(String sourceDocumentId, String sourceParentDocumentId, String targetParentDocumentId) throws FileNotFoundException {
        File sourceFile = getFileForDocId(sourceDocumentId, true);
        File targetParentFile = getFileForDocId(targetParentDocumentId, true);
        if (sourceFile != null && targetParentFile != null) {
            File targetFile = new File(targetParentFile, sourceFile.getName());
            if (!targetFile.exists() && sourceFile.renameTo(targetFile)) {
                return targetParentDocumentId + "/" + targetFile.getName();
            }
        }
        throw new FileNotFoundException("Failed to move document " + sourceDocumentId + " to " + targetParentDocumentId);
    }

    @Override
    public final boolean onCreate() {
        return true;
    }

    @Override
    public final ParcelFileDescriptor openDocument(String documentId, String mode, CancellationSignal cancellationSignal) throws FileNotFoundException {
        File file = getFileForDocId(documentId, false);
        if (file != null) {
            return ParcelFileDescriptor.open(file, ParcelFileDescriptor.parseMode(mode));
        } else {
            throw new FileNotFoundException(documentId + " not found");
        }
    }

    @Override
    public final Cursor queryChildDocuments(String parentDocumentId, String[] projection, String sortOrder) throws FileNotFoundException {
        if (parentDocumentId.endsWith("/")) {
            parentDocumentId = parentDocumentId.substring(0, parentDocumentId.length() - 1);
        }
        
        MatrixCursor cursor = new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
        File parent = getFileForDocId(parentDocumentId, true);
        
        // Virtual root - list available virtual directories (like Termux)
        if (parent == null) {
            // Show "files" and "data" as virtual directories
            includeFile(cursor, parentDocumentId + "/files", this.filesDir);
            includeFile(cursor, parentDocumentId + "/data", this.dataDir);
        } else {
            File[] children = parent.listFiles();
            if (children != null) {
                for (File child : children) {
                    includeFile(cursor, parentDocumentId + "/" + child.getName(), child);
                }
            }
        }
        return cursor;
    }

    @Override
    public final Cursor queryDocument(String documentId, String[] projection) throws FileNotFoundException {
        MatrixCursor result = new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
        includeFile(result, documentId, null);
        return result;
    }

    @Override
    public final Cursor queryRoots(String[] projection) {
        ApplicationInfo appInfo = Objects.requireNonNull(getContext()).getApplicationInfo();
        String title = appInfo.loadLabel(getContext().getPackageManager()).toString();

        MatrixCursor result = new MatrixCursor(projection != null ? projection : DEFAULT_ROOT_PROJECTION);
        MatrixCursor.RowBuilder row = result.newRow();
        row.add(Root.COLUMN_ROOT_ID, this.pkgName);
        row.add(Root.COLUMN_DOCUMENT_ID, this.pkgName);
        row.add(Root.COLUMN_SUMMARY, "XoDos File Manager");
        row.add(Root.COLUMN_FLAGS, 
            Root.FLAG_SUPPORTS_CREATE | 
            Root.FLAG_SUPPORTS_SEARCH | 
            Root.FLAG_SUPPORTS_IS_CHILD |
            Root.FLAG_LOCAL_ONLY);
        row.add(Root.COLUMN_TITLE, title);
        row.add(Root.COLUMN_MIME_TYPES, "*/*");
        row.add(Root.COLUMN_AVAILABLE_BYTES, filesDir.getFreeSpace());
        row.add(Root.COLUMN_ICON, appInfo.icon);
        return result;
    }

    @Override
    public final void removeDocument(String documentId, String parentDocumentId) throws FileNotFoundException {
        deleteDocument(documentId);
    }

    @Override
    public final String renameDocument(String documentId, String displayName) throws FileNotFoundException {
        File file = getFileForDocId(documentId, true);
        if (file == null || !file.renameTo(new File(file.getParentFile(), displayName))) {
            throw new FileNotFoundException("Failed to rename document " + documentId + " to " + displayName);
        }
        int parentIdx = documentId.lastIndexOf('/', documentId.length() - 2);
        return documentId.substring(0, parentIdx) + "/" + displayName;
    }
}