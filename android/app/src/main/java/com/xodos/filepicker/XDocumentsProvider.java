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
 * Enhanced DocumentsProvider with full control including permissions and symlink support
 * Based on MTDataFilesProvider with Wine app data folder access
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
    private File dataDir;
    private File wineDataDir;

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
        
        // Initialize Wine data directory - you can modify this path as needed
        this.wineDataDir = new File("/data/data/com.wine.app");
        if (!wineDataDir.exists() || !wineDataDir.canRead()) {
            // Fallback to alternative Wine paths
            wineDataDir = new File("/data/data/com.winehq.wine");
            if (!wineDataDir.exists() || !wineDataDir.canRead()) {
                wineDataDir = null;
            }
        }
    }

    /**
     * Get file object by documentId
     */
    private final File getFileForDocId(String documentId, boolean lsFileState) throws FileNotFoundException {
        String realPath;
        if (!documentId.startsWith(this.pkgName)) {
            throw new FileNotFoundException(documentId.concat(" not found"));
        }

        // Get virtual name after package name
        String virtualName = documentId.substring(this.pkgName.length());
        if (virtualName.startsWith("/")) {
            virtualName = virtualName.substring(1);
        }
        
        // Self (root)
        if (virtualName.isEmpty()) {
            return null;
        }
        
        String[] split = virtualName.split("/", 2);
        virtualName = split[0];
        realPath = split.length > 1 ? split[1] : "";

        File targetFile;
        if (virtualName.equalsIgnoreCase("data")) {
            targetFile = new File(this.dataDir, realPath);
        } else if (virtualName.equalsIgnoreCase("wine_data") && this.wineDataDir != null) {
            targetFile = new File(this.wineDataDir, realPath);
        } else {
            throw new FileNotFoundException(documentId.concat(" not found"));
        }

        if (lsFileState) {
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
            List<String> pathSegments = ((Uri) extras.getParcelable("uri")).getPathSegments();
            String documentId = pathSegments.size() >= 4 ? pathSegments.get(3) : pathSegments.get(1);
            switch (method) {
                case "mt:setPermissions": {
                    File file = getFileForDocId(documentId, true);
                    if (file != null) {
                        Os.chmod(file.getPath(), extras.getInt("permissions"));
                        customBundle.putBoolean("result", true);
                    }
                    return customBundle;
                }
                case "mt:createSymlink": {
                    File file = getFileForDocId(documentId, false);
                    if (file != null) {
                        Os.symlink(extras.getString("path"), file.getPath());
                        customBundle.putBoolean("result", true);
                    }
                    return customBundle;
                }
                case "mt:setLastModified": {
                    File file = getFileForDocId(documentId, true);
                    if (file != null) {
                        customBundle.putBoolean("result", file.setLastModified(extras.getLong("time")));
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
                    return parentDocumentId +
                        (parentDocumentId.endsWith("/") ? "" : "/") +
                        newFile.getName();
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

        // Root directory
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
                Document.FLAG_SUPPORTS_RENAME);
            return;
        }

        int flags = 0;
        if (file.isDirectory()) {
            flags |= Document.FLAG_DIR_SUPPORTS_CREATE;
            if (file.canWrite()) {
                flags |= Document.FLAG_SUPPORTS_DELETE | Document.FLAG_SUPPORTS_RENAME;
            }
        } else {
            if (file.canRead()) {
                // Reading is always supported for files that exist
                // No specific flag needed for read support
            }
            if (file.canWrite()) {
                flags |= Document.FLAG_SUPPORTS_WRITE | Document.FLAG_SUPPORTS_DELETE | 
                         Document.FLAG_SUPPORTS_RENAME;
            }
        }

        // Add copy and move support for both files and directories
        if (file.canRead()) {
            flags |= Document.FLAG_SUPPORTS_COPY | Document.FLAG_SUPPORTS_MOVE;
        }

        String displayName;
        String path = file.getPath();
        boolean isNormalFile = true;

        // Virtual directories
        if (path.equals(this.dataDir.getPath())) {
            displayName = "App Data";
            isNormalFile = false;
        } else if (wineDataDir != null && path.equals(wineDataDir.getPath())) {
            displayName = "Wine Data";
            isNormalFile = false;
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
        
        if (isNormalFile) {
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
                return targetParentDocumentId
                    + (targetParentDocumentId.endsWith("/") ? "" : "/")
                    + targetFile.getName();
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
        
        // Virtual root - list available data directories
        if (parent == null) {
            includeFile(cursor, parentDocumentId.concat("/data"), this.dataDir);
            if (wineDataDir != null && wineDataDir.exists()) {
                includeFile(cursor, parentDocumentId.concat("/wine_data"), this.wineDataDir);
            }
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
        row.add(Root.COLUMN_SUMMARY, "Full control file manager with Wine support");
        row.add(Root.COLUMN_FLAGS, 
            Root.FLAG_SUPPORTS_CREATE | 
            Root.FLAG_SUPPORTS_SEARCH | 
            Root.FLAG_SUPPORTS_IS_CHILD |
            Root.FLAG_LOCAL_ONLY);
        row.add(Root.COLUMN_TITLE, title);
        row.add(Root.COLUMN_MIME_TYPES, "*/*");
        row.add(Root.COLUMN_AVAILABLE_BYTES, dataDir.getFreeSpace());
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