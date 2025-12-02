package com.xodos.filepicker;

import android.annotation.SuppressLint;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.os.Bundle;
import android.os.CancellationSignal;
import android.os.ParcelFileDescriptor;
import android.provider.DocumentsContract;
import android.provider.DocumentsProvider;
import android.system.ErrnoException;
import android.system.Os;
import android.system.StructStat;
import android.webkit.MimeTypeMap;


import java.io.File;
import java.io.FileNotFoundException;
import java.util.Arrays;

public class XDocumentsProvider extends DocumentsProvider {

    private static final String ROOT_ID = "xodos";
    private File baseDir;

    @Override
    public boolean onCreate() {
        baseDir = getContext().getFilesDir();  // /data/data/com.xodos/files
        return true;
    }

    // ---------------------------
    //  SAF ROOT
    // ---------------------------
    @Override
    public Cursor queryRoots(String[] projection) {
        final MatrixCursor result = new MatrixCursor(resolveRootProjection(projection));

        final MatrixCursor.RowBuilder row = result.newRow();
        row.add(DocumentsContract.Root.COLUMN_ROOT_ID, ROOT_ID);
        row.add(DocumentsContract.Root.COLUMN_TITLE, "XoDos Files");
        row.add(DocumentsContract.Root.COLUMN_DOCUMENT_ID, getDocIdForFile(baseDir));
        row.add(DocumentsContract.Root.COLUMN_ICON, getContext().getApplicationInfo().icon); // app icon
        row.add(DocumentsContract.Root.COLUMN_FLAGS,
                DocumentsContract.Root.FLAG_LOCAL_ONLY |
                DocumentsContract.Root.FLAG_SUPPORTS_CREATE |
                DocumentsContract.Root.FLAG_SUPPORTS_RECENTS |
                DocumentsContract.Root.FLAG_SUPPORTS_SEARCH);

        row.add(DocumentsContract.Root.COLUMN_AVAILABLE_BYTES, baseDir.getFreeSpace());

        return result;
    }

    // ---------------------------
    //   DOCUMENT ID ↔ FILE
    // ---------------------------
    private String getDocIdForFile(File file) {
        String path = file.getAbsolutePath();
        String base = baseDir.getAbsolutePath();

        if (path.equals(base)) return ROOT_ID + ":/";

        String relative = path.substring(base.length());
        if (!relative.startsWith("/")) relative = "/" + relative;

        return ROOT_ID + ":" + relative;
    }

    private File getFileForDocId(String docId) throws FileNotFoundException {
        if (!docId.startsWith(ROOT_ID + ":"))
            throw new FileNotFoundException("Invalid root");

        String rel = docId.substring((ROOT_ID + ":").length());
        File target = new File(baseDir, rel);

        try { return target.getCanonicalFile(); }
        catch (Exception e) { return target; }
    }

    // ---------------------------
    //   DOCUMENT METADATA
    // ---------------------------
    @Override
    public Cursor queryDocument(String documentId, String[] projection)
            throws FileNotFoundException {

        final MatrixCursor result = new MatrixCursor(resolveDocumentProjection(projection));
        includeFile(result, documentId, getFileForDocId(documentId));
        return result;
    }

    @Override
    public Cursor queryChildDocuments(String parentDocId, String[] projection,
                                      String sortOrder) throws FileNotFoundException {

        final MatrixCursor result = new MatrixCursor(resolveDocumentProjection(projection));
        File parent = getFileForDocId(parentDocId);

        File[] files = parent.listFiles();
        if (files == null) files = new File[0];

        Arrays.sort(files);

        for (File file : files)
            includeFile(result, null, file);

        return result;
    }

    // ---------------------------
    //   OPEN DOCUMENT
    // ---------------------------
    @Override
    public ParcelFileDescriptor openDocument(String documentId, String mode,
                                             CancellationSignal signal)
            throws FileNotFoundException {

        File file = getFileForDocId(documentId);

        int accessMode = ParcelFileDescriptor.parseMode(mode);
        return ParcelFileDescriptor.open(file, accessMode);
    }

    // ---------------------------
    //   CREATE DOCUMENT
    // ---------------------------
    @Override
    public String createDocument(String parentDocId, String mimeType, String displayName)
            throws FileNotFoundException {

        File parent = getFileForDocId(parentDocId);
        File file = new File(parent, displayName);

        try {
            if (MimeTypeMap.getSingleton().hasExtension(mimeType))
                file.createNewFile();
            else
                file.mkdir();
        } catch (Exception e) {
            throw new FileNotFoundException("Failed: " + e);
        }

        return getDocIdForFile(file);
    }

    // ---------------------------
    //   DELETE DOCUMENT
    // ---------------------------
    @Override
    public void deleteDocument(String documentId) throws FileNotFoundException {
        File file = getFileForDocId(documentId);
        deleteRecursively(file);
    }

    private void deleteRecursively(File file) throws FileNotFoundException {
        if (!file.exists()) return;

        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null)
                for (File c : children) deleteRecursively(c);
        }

        if (!file.delete())
            throw new FileNotFoundException("Failed to delete " + file);
    }

    // ---------------------------
    //   RENAME DOCUMENT
    // ---------------------------
    @Override
    public String renameDocument(String documentId, String newName)
            throws FileNotFoundException {

        File file = getFileForDocId(documentId);
        File newFile = new File(file.getParentFile(), newName);

        if (!file.renameTo(newFile))
            throw new FileNotFoundException("Rename failed");

        return getDocIdForFile(newFile);
    }

    // ---------------------------
    //   PROVIDER METADATA FILLER
    // ---------------------------
    @SuppressLint("Range")
    private void includeFile(MatrixCursor result, String originalDocId, File file) {
        String docId = originalDocId != null ? originalDocId : getDocIdForFile(file);
        MatrixCursor.RowBuilder row = result.newRow();

        row.add(DocumentsContract.Document.COLUMN_DOCUMENT_ID, docId);
        row.add(DocumentsContract.Document.COLUMN_DISPLAY_NAME, file.getName());

        if (file.isDirectory()) {
            row.add(DocumentsContract.Document.COLUMN_MIME_TYPE,
                    DocumentsContract.Document.MIME_TYPE_DIR);
        } else {
            row.add(DocumentsContract.Document.COLUMN_MIME_TYPE,
                    getMimeType(file.getName()));
        }

        row.add(DocumentsContract.Document.COLUMN_SIZE, file.isFile() ? file.length() : 0);
        row.add(DocumentsContract.Document.COLUMN_LAST_MODIFIED, file.lastModified());

        int flags = DocumentsContract.Document.FLAG_SUPPORTS_DELETE |
                DocumentsContract.Document.FLAG_SUPPORTS_RENAME |
                DocumentsContract.Document.FLAG_SUPPORTS_WRITE;

        if (file.isDirectory())
            flags |= DocumentsContract.Document.FLAG_DIR_SUPPORTS_CREATE;

        row.add(DocumentsContract.Document.COLUMN_FLAGS, flags);
    }

    private String getMimeType(String name) {
        int i = name.lastIndexOf('.');
        if (i >= 0) {
            String ext = name.substring(i + 1).toLowerCase();
            String mt = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
            if (mt != null) return mt;
        }
        return "application/octet-stream";
    }

    // ---------------------------
    //   CUSTOM PERMISSIONS (chmod)
    // ---------------------------
    @Override
    public Bundle call(String method, String arg, Bundle extras) {
        if (!method.startsWith("mt:"))
            return super.call(method, arg, extras);

        Bundle result = new Bundle();
        result.putBoolean("result", false);

        try {
            File file = getFileForDocId(arg);

            switch (method) {

                case "mt:setPermissions": {
                    int mode = extras.getInt("permissions");
                    Os.chmod(file.getAbsolutePath(), mode);
                    result.putBoolean("result", true);
                    break;
                }

                case "mt:getPermissions": {
                    StructStat st = Os.lstat(file.getAbsolutePath());
                    result.putInt("permissions", st.st_mode);
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
            }

        } catch (ErrnoException | FileNotFoundException e) {
            result.putString("error", e.toString());
        }

        return result;
    }

    // ---------------------------
    //   PROJECTION HELPERS
    // ---------------------------
    private String[] resolveRootProjection(String[] projection) {
        return projection != null ? projection : new String[] {
                DocumentsContract.Root.COLUMN_ROOT_ID,
                DocumentsContract.Root.COLUMN_TITLE,
                DocumentsContract.Root.COLUMN_DOCUMENT_ID,
                DocumentsContract.Root.COLUMN_FLAGS,
                DocumentsContract.Root.COLUMN_ICON
        };
    }

    private String[] resolveDocumentProjection(String[] projection) {
        return projection != null ? projection : new String[] {
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                DocumentsContract.Document.COLUMN_SIZE,
                DocumentsContract.Document.COLUMN_MIME_TYPE,
                DocumentsContract.Document.COLUMN_LAST_MODIFIED,
                DocumentsContract.Document.COLUMN_FLAGS
        };
    }
}