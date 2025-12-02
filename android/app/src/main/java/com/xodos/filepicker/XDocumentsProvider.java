package com.xodos.filepicker;

import android.database.Cursor;
import android.database.MatrixCursor;
import android.graphics.Point;
import android.os.CancellationSignal;
import android.os.ParcelFileDescriptor;
import android.content.res.AssetFileDescriptor;
import android.provider.DocumentsContract.Document;
import android.provider.DocumentsContract.Root;
import android.provider.DocumentsProvider;

import android.content.Context;
import android.webkit.MimeTypeMap;
import java.io.File;
import java.io.FileNotFoundException;

public class XDocumentsProvider extends DocumentsProvider {

    private File baseDir;
    private static final String ROOT_ID = "XODOS_ROOT";

    private static final String[] DEFAULT_ROOT_PROJECTION = new String[]{
            Root.COLUMN_ROOT_ID,
            Root.COLUMN_DOCUMENT_ID,
            Root.COLUMN_TITLE,
            Root.COLUMN_FLAGS,
            Root.COLUMN_ICON,
            Root.COLUMN_MIME_TYPES,
            Root.COLUMN_AVAILABLE_BYTES
    };

    private static final String[] DEFAULT_DOCUMENT_PROJECTION = new String[]{
            Document.COLUMN_DOCUMENT_ID,
            Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_SIZE,
            Document.COLUMN_MIME_TYPE,
            Document.COLUMN_LAST_MODIFIED,
            Document.COLUMN_FLAGS
    };

    @Override
    public boolean onCreate() {
        Context ctx = getContext();
        baseDir = new File(ctx.getFilesDir().getAbsolutePath());
        return true;
    }

    @Override
    public Cursor queryRoots(String[] projection) {
        final MatrixCursor result =
                new MatrixCursor(projection != null ? projection : DEFAULT_ROOT_PROJECTION);

        MatrixCursor.RowBuilder row = result.newRow();
        row.add(Root.COLUMN_ROOT_ID, ROOT_ID);
        row.add(Root.COLUMN_DOCUMENT_ID, ROOT_ID);
        row.add(Root.COLUMN_TITLE, "XoDos Files");
        row.add(Root.COLUMN_MIME_TYPES, "*/*");
        row.add(Root.COLUMN_FLAGS,
                Root.FLAG_SUPPORTS_CREATE |
                        Root.FLAG_SUPPORTS_SEARCH |
                        Root.FLAG_SUPPORTS_RECENTS |
                        Root.FLAG_LOCAL_ONLY);
        row.add(Root.COLUMN_AVAILABLE_BYTES, baseDir.getFreeSpace());
        row.add(Root.COLUMN_ICON, android.R.drawable.ic_menu_manage);

        return result;
    }

    @Override
    public Cursor queryDocument(String documentId, String[] projection)
            throws FileNotFoundException {
        final MatrixCursor result =
                new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);

        includeFile(result, documentId, getFileForDocId(documentId));
        return result;
    }

    @Override
    public Cursor queryChildDocuments(String parentDocumentId, String[] projection,
                                      String sortOrder) throws FileNotFoundException {
        final MatrixCursor result =
                new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);

        File parent = getFileForDocId(parentDocumentId);
        File[] files = parent.listFiles();

        if (files != null) {
            for (File file : files) {
                includeFile(result, null, file);
            }
        }
        return result;
    }

    @Override
    public ParcelFileDescriptor openDocument(String documentId, String mode,
                                             CancellationSignal signal)
            throws FileNotFoundException {

        File file = getFileForDocId(documentId);

        int accessMode = ParcelFileDescriptor.MODE_READ_ONLY;
        if (mode.contains("w")) {
            accessMode = ParcelFileDescriptor.MODE_READ_WRITE |
                    ParcelFileDescriptor.MODE_CREATE |
                    ParcelFileDescriptor.MODE_TRUNCATE;
        }

        return ParcelFileDescriptor.open(file, accessMode);
    }

    @Override
    public AssetFileDescriptor openDocumentThumbnail(String documentId, Point size,
                                                     CancellationSignal signal)
            throws FileNotFoundException {
        File file = getFileForDocId(documentId);
        return new AssetFileDescriptor(
                ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY),
                0,
                AssetFileDescriptor.UNKNOWN_LENGTH
        );
    }

    private File getFileForDocId(String docId) throws FileNotFoundException {
        if (docId.equals(ROOT_ID)) return baseDir;
        File file = new File(docId);
        if (!file.exists()) throw new FileNotFoundException(docId);
        return file;
    }

    private void includeFile(MatrixCursor result, String documentId, File file)
            throws FileNotFoundException {
        if (documentId == null) documentId = file.getAbsolutePath();
        final MatrixCursor.RowBuilder row = result.newRow();
        row.add(Document.COLUMN_DOCUMENT_ID, documentId);
        row.add(Document.COLUMN_DISPLAY_NAME, file.getName());
        row.add(Document.COLUMN_SIZE, file.length());
        row.add(Document.COLUMN_LAST_MODIFIED, file.lastModified());

        if (file.isDirectory()) {
            row.add(Document.COLUMN_MIME_TYPE, Document.MIME_TYPE_DIR);
            row.add(Document.COLUMN_FLAGS,
                    Document.FLAG_DIR_SUPPORTS_CREATE |
                            Document.FLAG_SUPPORTS_DELETE |
                            Document.FLAG_SUPPORTS_WRITE);
        } else {
            row.add(Document.COLUMN_MIME_TYPE, getMimeType(file));
            row.add(Document.COLUMN_FLAGS,
                    Document.FLAG_SUPPORTS_WRITE |
                            Document.FLAG_SUPPORTS_DELETE |
                            Document.FLAG_SUPPORTS_READ);
        }
    }

    private String getMimeType(File file) {
        String ext = MimeTypeMap.getFileExtensionFromUrl(file.getName()).toLowerCase();
        if (ext.isEmpty()) return "application/octet-stream";
        String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
        return mime != null ? mime : "application/octet-stream";
    }
}