package com.com.xodos.filepicker;

import static android.provider.DocumentsContract.Document.MIME_TYPE_DIR;

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
import android.system.OsConstants;
import android.system.StructStat;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Objects;

/**
 * XDocumentsProvider for XoDos - exposes app private data and provides
 * custom mt:* calls for permission control and symlink creation.
 *
 * Adapted from MTDataFilesProvider style.
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
    private File dataDir; // parent of getFilesDir() -> /data/data/<pkg>
    private static final File BASE_DIR = new File("/data"); // used only for available bytes if needed

    @SuppressLint("SdCardPath")
    @Override
    public final void attachInfo(Context context, ProviderInfo info) {
        super.attachInfo(context, info);
        this.pkgName = Objects.requireNonNull(getContext()).getPackageName();
        // parent of files dir is the app data dir (/data/data/<pkg>)
        this.dataDir = Objects.requireNonNull(context.getFilesDir()).getParentFile();
    }

    /**
     * Delete file or directory recursively. For symlinked directories it will delete only the link.
     */
    private static boolean deleteFileOrDirectory(File file) {
        if (file.isDirectory()) {
            boolean isSymlink = false;
            try {
                StructStat st = Os.lstat(file.getPath());
                isSymlink = (st.st_mode & OsConstants.S_IFMT) == OsConstants.S_IFLNK;
            } catch (ErrnoException e) {
                // ignore, treat as not symlink if lstat fails
            }

            File[] children = file.listFiles();
            if (!isSymlink && children != null) {
                for (File c : children) {
                    if (!deleteFileOrDirectory(c)) return false;
                }
            }
        }
        return file.delete();
    }

    private static String getMimeType(File file) {
        if (file.isDirectory()) return MIME_TYPE_DIR;
        String name = file.getName();
        int lastDot = name.lastIndexOf('.');
        if (lastDot >= 0) {
            String extension = name.substring(lastDot + 1).toLowerCase();
            String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
            if (mime != null) return mime;
        }
        return "application/octet-stream";
    }

    /**
     * Maps a documentId to a real File. Format:
     *   <pkg>                     -> virtual root (returns null)
     *   <pkg>/data/...            -> maps to /data/data/<pkg>/...  (private data)
     *
     * If lsFileState==true we verify file exists using Os.lstat (to detect broken links).
     */
    private final File getFileForDocId(String documentId, boolean lsFileState) throws FileNotFoundException {
        if (!documentId.startsWith(this.pkgName))
            throw new FileNotFoundException(documentId + " not found");

        String virtual = documentId.substring(this.pkgName.length());
        if (virtual.startsWith("/")) virtual = virtual.substring(1);

        if (virtual.isEmpty()) {
            // virtual root
            return null;
        }

        String[] parts = virtual.split("/", 2);
        String virtualName = parts[0];
        String realPathSuffix = parts.length > 1 ? parts[1] : "";

        File target;
        if ("data".equalsIgnoreCase(virtualName)) {
            target = new File(this.dataDir, realPathSuffix);
        } else {
            // unsupported virtual namespace
            throw new FileNotFoundException(documentId + " not found");
        }

        if (lsFileState) {
            try {
                Os.lstat(target.getPath());
            } catch (Exception e) {
                throw new FileNotFoundException(documentId + " not found");
            }
        }
        return target;
    }

    /**
     * Implement custom calls for permission & symlink actions.
     * Methods:
     *   mt:setPermissions -> requires extras.putInt("permissions", mode)
     *   mt:createSymlink  -> requires extras.putString("path", targetPath)
     *   mt:setLastModified -> requires extras.putLong("time", millis)
     */
    @Override
    public final Bundle call(String method, String arg, Bundle extras) {
        Bundle superBundle = super.call(method, arg, extras);
        if (superBundle != null) return superBundle;

        if (method == null || !method.startsWith("mt:")) return null;

        Bundle out = new Bundle();
        out.putBoolean("result", false);

        try {
            Uri uri = extras != null ? (Uri) extras.getParcelable("uri") : null;
            String documentId = null;
            if (uri != null) {
                // document URI path segments: content, <authority>, tree, <documentId>... this can vary;
                // fallback to arg if provided.
                int segs = uri.getPathSegments().size();
                if (segs >= 1) {
                    // try best-effort: the document id is often at index 1 or 3; if uri path contains pkgName substring, find it.
                    for (String s : uri.getPathSegments()) {
                        if (s != null && s.startsWith(this.pkgName)) {
                            documentId = s;
                            break;
                        }
                    }
                }
            }
            if (documentId == null && arg != null) {
                documentId = arg;
            }
            if (documentId == null) {
                out.putString("message", "documentId missing");
                return out;
            }

            switch (method) {
                case "mt:setPermissions": {
                    File f = getFileForDocId(documentId, true);
                    if (f != null && extras != null && extras.containsKey("permissions")) {
                        int perms = extras.getInt("permissions");
                        Os.chmod(f.getPath(), perms);
                        out.putBoolean("result", true);
                    }
                    return out;
                }
                case "mt:createSymlink": {
                    File f = getFileForDocId(documentId, false);
                    if (f != null && extras != null && extras.containsKey("path")) {
                        String target = extras.getString("path");
                        Os.symlink(target, f.getPath());
                        out.putBoolean("result", true);
                    }
                    return out;
                }
                case "mt:setLastModified": {
                    File f = getFileForDocId(documentId, true);
                    if (f != null && extras != null && extras.containsKey("time")) {
                        boolean ok = f.setLastModified(extras.getLong("time"));
                        out.putBoolean("result", ok);
                    }
                    return out;
                }
                default:
                    out.putString("message", "Unsupported method: " + method);
                    return out;
            }
        } catch (ErrnoException ee) {
            out.putBoolean("result", false);
            out.putString("message", "ErrnoException: " + ee.toString());
            return out;
        } catch (Exception e) {
            out.putBoolean("result", false);
            out.putString("message", e.toString());
            return out;
        }
    }

    @Override
    public final String createDocument(String parentDocumentId, String mimeType, String displayName) throws FileNotFoundException {
        File parent = getFileForDocId(parentDocumentId, true);
        if (parent != null) {
            File newFile = new File(parent, displayName);
            int counter = 2;
            while (newFile.exists()) {
                newFile = new File(parent, displayName + " (" + counter + ")");
                counter++;
            }
            try {
                boolean success = MIME_TYPE_DIR.equals(mimeType) ? newFile.mkdir() : newFile.createNewFile();
                if (success) {
                    return parentDocumentId + (parentDocumentId.endsWith("/") ? "" : "/") + newFile.getName();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        throw new FileNotFoundException("Failed to create document in " + parentDocumentId + " with name " + displayName);
    }

    /**
     * Add a file representation to a cursor. If file==null then this is the virtual root.
     */
    private void includeFile(MatrixCursor result, String docId, File file) throws FileNotFoundException {
        if (file == null) {
            Context ctx = getContext();
            String title = ctx == null ? "XoDos" : ctx.getApplicationInfo().loadLabel(ctx.getPackageManager()).toString();
            MatrixCursor.RowBuilder row = result.newRow();
            row.add(Document.COLUMN_DOCUMENT_ID, this.pkgName);
            row.add(Document.COLUMN_DISPLAY_NAME, title);
            row.add(Document.COLUMN_SIZE, 0);
            row.add(Document.COLUMN_MIME_TYPE, MIME_TYPE_DIR);
            row.add(Document.COLUMN_LAST_MODIFIED, 0);
            row.add(Document.COLUMN_FLAGS, 0);
            return;
        }

        int flags = 0;
        if (file.isDirectory()) {
            if (file.canWrite()) flags |= Document.FLAG_DIR_SUPPORTS_CREATE;
        } else {
            if (file.canWrite()) flags |= Document.FLAG_SUPPORTS_WRITE;
        }
        if (file.getParentFile() != null && file.getParentFile().canWrite()) flags |= Document.FLAG_SUPPORTS_DELETE;

        String displayName;
        boolean isNormalFile = true;
        if (file.getPath().equals(this.dataDir.getPath())) {
            displayName = "data";
            isNormalFile = false;
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

        if (isNormalFile) {
            try {
                StructStat st = Os.lstat(file.getPath());
                StringBuilder sb = new StringBuilder()
                        .append(st.st_mode)
                        .append("|").append(st.st_uid)
                        .append("|").append(st.st_gid);
                if ((st.st_mode & OsConstants.S_IFMT) == OsConstants.S_IFLNK) {
                    sb.append("|").append(Os.readlink(file.getPath()));
                }
                row.add("mt_extras", sb.toString());
            } catch (Exception e) {
                // ignore extras if lstat fails
            }
        }
    }

    @Override
    public final void deleteDocument(String documentId) throws FileNotFoundException {
        File f = getFileForDocId(documentId, true);
        if (f == null || !deleteFileOrDirectory(f)) {
            throw new FileNotFoundException("Failed to delete document " + documentId);
        }
    }

    @Override
    public final String getDocumentType(String documentId) throws FileNotFoundException {
        File f = getFileForDocId(documentId, true);
        return f == null ? MIME_TYPE_DIR : getMimeType(f);
    }

    @Override
    public final boolean isChildDocument(String parentDocumentId, String documentId) {
        return documentId != null && documentId.startsWith(parentDocumentId);
    }

    @Override
    public final String moveDocument(String sourceDocumentId, String sourceParentDocumentId, String targetParentDocumentId) throws FileNotFoundException {
        File source = getFileForDocId(sourceDocumentId, true);
        File targetParent = getFileForDocId(targetParentDocumentId, true);
        if (source != null && targetParent != null) {
            File target = new File(targetParent, source.getName());
            if (!target.exists() && source.renameTo(target)) {
                return targetParentDocumentId + (targetParentDocumentId.endsWith("/") ? "" : "/") + target.getName();
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
        File f = getFileForDocId(documentId, false);
        if (f != null) {
            return ParcelFileDescriptor.open(f, ParcelFileDescriptor.parseMode(mode));
        } else {
            throw new FileNotFoundException(documentId + " not found");
        }
    }

    @Override
    public final Cursor queryChildDocuments(String parentDocumentId, String[] projection, String sortOrder) throws FileNotFoundException {
        if (parentDocumentId.endsWith("/")) parentDocumentId = parentDocumentId.substring(0, parentDocumentId.length() - 1);
        MatrixCursor cursor = new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
        File parent = getFileForDocId(parentDocumentId, true);

        if (parent == null) {
            // virtual root -> expose 'data' (app private dir)
            includeFile(cursor, parentDocumentId + "/data", this.dataDir);
        } else {
            File[] children = parent.listFiles();
            if (children != null) {
                for (File c : children) {
                    includeFile(cursor, parentDocumentId + "/" + c.getName(), c);
                }
            }
        }
        return cursor;
    }

    @Override
    public final Cursor queryDocument(String documentId, String[] projection) throws FileNotFoundException {
        MatrixCursor cursor = new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
        includeFile(cursor, documentId, null);
        return cursor;
    }

    @Override
    public final Cursor queryRoots(String[] projection) {
        ApplicationInfo appInfo = Objects.requireNonNull(getContext()).getApplicationInfo();
        String title = appInfo.loadLabel(getContext().getPackageManager()).toString();

        MatrixCursor result = new MatrixCursor(projection != null ? projection : DEFAULT_ROOT_PROJECTION);
        MatrixCursor.RowBuilder row = result.newRow();
        row.add(Root.COLUMN_ROOT_ID, this.pkgName);
        row.add(Root.COLUMN_DOCUMENT_ID, this.pkgName);
        row.add(Root.COLUMN_SUMMARY, this.pkgName);
        row.add(Root.COLUMN_FLAGS, Root.FLAG_SUPPORTS_CREATE | Root.FLAG_SUPPORTS_SEARCH | Root.FLAG_SUPPORTS_IS_CHILD);
        row.add(Root.COLUMN_TITLE, title);
        row.add(Root.COLUMN_MIME_TYPES, "*/*");
        row.add(Root.COLUMN_AVAILABLE_BYTES, BASE_DIR.getFreeSpace());
        row.add(Root.COLUMN_ICON, appInfo.icon);
        return result;
    }

    @Override
    public final void removeDocument(String documentId, String parentDocumentId) throws FileNotFoundException {
        deleteDocument(documentId);
    }

    @Override
    public final String renameDocument(String documentId, String displayName) throws FileNotFoundException {
        File b = getFileForDocId(documentId, true);
        if (b == null || !b.renameTo(new File(b.getParentFile(), displayName))) {
            throw new FileNotFoundException("Failed to rename document " + documentId + " to " + displayName);
        }
        int parentIdx = documentId.lastIndexOf('/', documentId.length() - 2);
        return documentId.substring(0, parentIdx) + "/" + displayName;
    }
}