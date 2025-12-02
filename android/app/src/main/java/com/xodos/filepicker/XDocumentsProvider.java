package com.xodos.filepicker;

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
    private File filesDir;

    @Override
    public boolean onCreate() {
        return true;
    }

    @SuppressLint("SdCardPath")
    @Override
    public void attachInfo(Context context, ProviderInfo info) {
        super.attachInfo(context, info);
        this.pkgName = Objects.requireNonNull(context).getPackageName();
        this.dataDir = Objects.requireNonNull(context.getFilesDir().getParentFile());
        this.filesDir = context.getFilesDir();
    }

    /**
     * Convert document ID to actual file
     */
    private File getFileForDocId(String documentId, boolean lsFileState) throws FileNotFoundException {
        if (!documentId.startsWith(pkgName)) {
            throw new FileNotFoundException(documentId + " not found");
        }

        // Get path after package name
        String virtualPath = documentId.substring(pkgName.length());
        if (virtualPath.startsWith("/")) {
            virtualPath = virtualPath.substring(1);
        }
        
        // Root directory
        if (virtualPath.isEmpty()) {
            return null;
        }
        
        String[] parts = virtualPath.split("/", 2);
        String virtualDir = parts[0];
        String relativePath = parts.length > 1 ? parts[1] : "";

        File targetFile;
        if (virtualDir.equals("data")) {
            targetFile = new File(dataDir, relativePath);
        } else if (virtualDir.equals("files")) {
            targetFile = new File(filesDir, relativePath);
        } else {
            throw new FileNotFoundException(documentId + " not found");
        }

        if (lsFileState && targetFile != null) {
            try {
                Os.lstat(targetFile.getPath());
            } catch (Exception e) {
                throw new FileNotFoundException(documentId + " not found");
            }
        }
        return targetFile;
    }

    @Override
    public Cursor queryRoots(String[] projection) throws FileNotFoundException {
        final MatrixCursor result = new MatrixCursor(projection != null ? projection : DEFAULT_ROOT_PROJECTION);
        
        ApplicationInfo appInfo = getContext().getApplicationInfo();
        String title = appInfo.loadLabel(getContext().getPackageManager()).toString();
        
        final MatrixCursor.RowBuilder row = result.newRow();
        row.add(Root.COLUMN_ROOT_ID, pkgName);
        row.add(Root.COLUMN_DOCUMENT_ID, pkgName);
        row.add(Root.COLUMN_TITLE, "XoDos Files");
        row.add(Root.COLUMN_SUMMARY, "XoDos internal storage");
        row.add(Root.COLUMN_FLAGS,
                Root.FLAG_LOCAL_ONLY |
                Root.FLAG_SUPPORTS_CREATE |
                Root.FLAG_SUPPORTS_RECENTS |
                Root.FLAG_SUPPORTS_SEARCH |
                Root.FLAG_SUPPORTS_IS_CHILD);
        row.add(Root.COLUMN_MIME_TYPES, "*/*");
        row.add(Root.COLUMN_AVAILABLE_BYTES, filesDir.getFreeSpace());
        row.add(Root.COLUMN_ICON, appInfo.icon);
        
        return result;
    }

    @Override
    public Cursor queryDocument(String documentId, String[] projection) throws FileNotFoundException {
        final MatrixCursor result = new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
        includeFile(result, documentId, null);
        return result;
    }

    @Override
    public Cursor queryChildDocuments(String parentDocumentId, String[] projection, String sortOrder) throws FileNotFoundException {
        final MatrixCursor result = new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
        
        File parent = getFileForDocId(parentDocumentId, true);
        
        if (parent == null) {
            // Root - show virtual directories
            includeFile(result, pkgName + "/data", dataDir);
            includeFile(result, pkgName + "/files", filesDir);
        } else {
            File[] children = parent.listFiles();
            if (children != null) {
                for (File child : children) {
                    includeFile(result, parentDocumentId + "/" + child.getName(), child);
                }
            }
        }
        
        return result;
    }

    private void includeFile(MatrixCursor result, String docId, File file) throws FileNotFoundException {
        if (file == null) {
            file = getFileForDocId(docId, true);
        }
        
        // Handle root
        if (file == null) {
            ApplicationInfo appInfo = getContext().getApplicationInfo();
            String title = appInfo.loadLabel(getContext().getPackageManager()).toString();
            
            MatrixCursor.RowBuilder row = result.newRow();
            row.add(Document.COLUMN_DOCUMENT_ID, pkgName);
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
            if (file.canWrite()) {
                flags |= Document.FLAG_SUPPORTS_WRITE | Document.FLAG_SUPPORTS_DELETE | 
                         Document.FLAG_SUPPORTS_RENAME;
            }
        }
        
        // Add copy/move support for readable files
        if (file.canRead()) {
            flags |= Document.FLAG_SUPPORTS_COPY | Document.FLAG_SUPPORTS_MOVE;
        }
        
        // Add settings flag for permission control
        flags |= Document.FLAG_SUPPORTS_SETTINGS;
        
        String displayName;
        if (file.getAbsolutePath().equals(dataDir.getAbsolutePath())) {
            displayName = "data";
        } else if (file.getAbsolutePath().equals(filesDir.getAbsolutePath())) {
            displayName = "files";
        } else {
            displayName = file.getName();
        }
        
        MatrixCursor.RowBuilder row = result.newRow();
        row.add(Document.COLUMN_DOCUMENT_ID, docId);
        row.add(Document.COLUMN_DISPLAY_NAME, displayName);
        row.add(Document.COLUMN_SIZE, file.length());
        row.add(Document.COLUMN_MIME_TYPE, getMimeType(file));
        row.add(Document.COLUMN_LAST_MODIFIED, file.lastModified());
        row.add(Document.COLUMN_FLAGS, flags);
        row.add("mt_path", file.getAbsolutePath());
        
        // Add extended file info
        try {
            StructStat stat = Os.lstat(file.getAbsolutePath());
            StringBuilder extras = new StringBuilder()
                .append(stat.st_mode)
                .append("|").append(stat.st_uid)
                .append("|").append(stat.st_gid);
            if ((stat.st_mode & S_IFMT) == S_IFLNK) {
                try {
                    extras.append("|").append(Os.readlink(file.getAbsolutePath()));
                } catch (ErrnoException e) {
                    // Ignore
                }
            }
            row.add("mt_extras", extras.toString());
        } catch (ErrnoException e) {
            // If we can't stat, don't add extras
        }
    }

    private String getMimeType(File file) {
        if (file.isDirectory()) {
            return MIME_TYPE_DIR;
        }
        
        String name = file.getName();
        int dot = name.lastIndexOf('.');
        if (dot >= 0) {
            String ext = name.substring(dot + 1).toLowerCase();
            String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
            if (mime != null) {
                return mime;
            }
        }
        return "application/octet-stream";
    }

    @Override
    public String getDocumentType(String documentId) throws FileNotFoundException {
        File file = getFileForDocId(documentId, true);
        return getMimeType(file);
    }

    @Override
    public ParcelFileDescriptor openDocument(String documentId, String mode, CancellationSignal signal) throws FileNotFoundException {
        File file = getFileForDocId(documentId, false);
        if (file != null) {
            int accessMode = ParcelFileDescriptor.parseMode(mode);
            return ParcelFileDescriptor.open(file, accessMode);
        } else {
            throw new FileNotFoundException(documentId + " not found");
        }
    }

    @Override
    public String createDocument(String parentDocumentId, String mimeType, String displayName) throws FileNotFoundException {
        File parent = getFileForDocId(parentDocumentId, true);
        if (parent != null) {
            File newFile = new File(parent, displayName);
            int counter = 2;
            while (newFile.exists()) {
                if (MIME_TYPE_DIR.equals(mimeType)) {
                    newFile = new File(parent, displayName + " (" + counter + ")");
                } else {
                    String name = displayName;
                    String ext = "";
                    int dot = displayName.lastIndexOf('.');
                    if (dot > 0) {
                        name = displayName.substring(0, dot);
                        ext = displayName.substring(dot);
                    }
                    newFile = new File(parent, name + " (" + counter + ")" + ext);
                }
                counter++;
            }
            
            try {
                boolean success;
                if (MIME_TYPE_DIR.equals(mimeType)) {
                    success = newFile.mkdir();
                } else {
                    success = newFile.createNewFile();
                }
                
                if (success) {
                    return parentDocumentId + "/" + newFile.getName();
                }
            } catch (IOException e) {
                throw new FileNotFoundException("Failed to create document: " + e.getMessage());
            }
        }
        throw new FileNotFoundException("Parent not found: " + parentDocumentId);
    }

    @Override
    public void deleteDocument(String documentId) throws FileNotFoundException {
        File file = getFileForDocId(documentId, true);
        if (file != null) {
            if (!deleteRecursive(file)) {
                throw new FileNotFoundException("Failed to delete " + documentId);
            }
        } else {
            throw new FileNotFoundException(documentId + " not found");
        }
    }
    
    private boolean deleteRecursive(File file) {
        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null) {
                for (File child : children) {
                    deleteRecursive(child);
                }
            }
        }
        return file.delete();
    }

    @Override
    public void removeDocument(String documentId, String parentDocumentId) throws FileNotFoundException {
        deleteDocument(documentId);
    }

    @Override
    public String renameDocument(String documentId, String displayName) throws FileNotFoundException {
        File file = getFileForDocId(documentId, true);
        if (file != null) {
            File newFile = new File(file.getParentFile(), displayName);
            if (file.renameTo(newFile)) {
                int lastSlash = documentId.lastIndexOf('/');
                if (lastSlash > 0) {
                    return documentId.substring(0, lastSlash) + "/" + displayName;
                } else {
                    return pkgName + "/" + displayName;
                }
            }
        }
        throw new FileNotFoundException("Failed to rename " + documentId);
    }

    @Override
    public String moveDocument(String sourceDocumentId, String sourceParentDocumentId, String targetParentDocumentId) throws FileNotFoundException {
        File source = getFileForDocId(sourceDocumentId, true);
        File targetParent = getFileForDocId(targetParentDocumentId, true);
        
        if (source != null && targetParent != null) {
            File target = new File(targetParent, source.getName());
            if (source.renameTo(target)) {
                return targetParentDocumentId + "/" + source.getName();
            }
        }
        throw new FileNotFoundException("Failed to move " + sourceDocumentId);
    }

    @Override
    public boolean isChildDocument(String parentDocumentId, String documentId) {
        return documentId.startsWith(parentDocumentId + "/");
    }

    @Override
    public Bundle call(String method, String arg, Bundle extras) {
        if (!method.startsWith("mt:")) {
            return super.call(method, arg, extras);
        }
        
        Bundle result = new Bundle();
        result.putBoolean("result", false);
        
        try {
            File file = getFileForDocId(arg, false);
            if (file != null) {
                switch (method) {
                    case "mt:setPermissions": {
                        int permissions = extras.getInt("permissions");
                        Os.chmod(file.getAbsolutePath(), permissions);
                        result.putBoolean("result", true);
                        break;
                    }
                    case "mt:createSymlink": {
                        String target = extras.getString("target");
                        Os.symlink(target, file.getAbsolutePath());
                        result.putBoolean("result", true);
                        break;
                    }
                    case "mt:setLastModified": {
                        long time = extras.getLong("time");
                        result.putBoolean("result", file.setLastModified(time));
                        break;
                    }
                    case "mt:getPermissions": {
                        StructStat stat = Os.lstat(file.getAbsolutePath());
                        result.putInt("permissions", stat.st_mode & 0777);
                        result.putBoolean("result", true);
                        break;
                    }
                }
            }
        } catch (Exception e) {
            result.putString("error", e.toString());
        }
        
        return result;
    }
}