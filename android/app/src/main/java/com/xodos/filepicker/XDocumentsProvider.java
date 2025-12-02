package com.xodos.filepicker;

import android.database.Cursor;
import android.database.MatrixCursor;
import android.provider.DocumentsContract;
import android.provider.DocumentsProvider;
import android.content.res.AssetFileDescriptor;
import android.os.ParcelFileDescriptor;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileNotFoundException;

public class XodosDataFilesProvider extends DocumentsProvider {

    private static final String ROOT_ID = "xodos_root";
    private static final String ROOT_PATH = "/data/data/com.xodos/files";

    private static final String[] DEFAULT_ROOT_PROJECTION = new String[]{
            DocumentsContract.Root.COLUMN_ROOT_ID,
            DocumentsContract.Root.COLUMN_TITLE,
            DocumentsContract.Root.COLUMN_DOCUMENT_ID,
            DocumentsContract.Root.COLUMN_FLAGS,
            DocumentsContract.Root.COLUMN_MIME_TYPES
    };

    private static final String[] DEFAULT_DOCUMENT_PROJECTION = new String[]{
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_SIZE,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_FLAGS,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED
    };

    @Override
    public boolean onCreate() {
        File root = new File(ROOT_PATH);
        if (!root.exists()) root.mkdirs();
        return true;
    }

    @Override
    public Cursor queryRoots(String[] projection) {
        final MatrixCursor cursor = new MatrixCursor(
                projection != null ? projection : DEFAULT_ROOT_PROJECTION);

        final MatrixCursor.RowBuilder row = cursor.newRow();
        row.add(DocumentsContract.Root.COLUMN_ROOT_ID, ROOT_ID);
        row.add(DocumentsContract.Root.COLUMN_TITLE, "Xodos Internal Files");
        row.add(DocumentsContract.Root.COLUMN_DOCUMENT_ID, ROOT_PATH);
        row.add(DocumentsContract.Root.COLUMN_FLAGS,
                DocumentsContract.Root.FLAG_LOCAL_ONLY
                        | DocumentsContract.Root.FLAG_SUPPORTS_CREATE);
        row.add(DocumentsContract.Root.COLUMN_MIME_TYPES, "*/*");

        return cursor;
    }

    private static String getMimeType(String fileName) {
        int dotPos = fileName.lastIndexOf('.');
        if (dotPos >= 0) {
            String ext = fileName.substring(dotPos + 1);
            String mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
            if (mime != null) return mime;
        }
        return DocumentsContract.Document.MIME_TYPE_DIR; // fallback
    }

    private Cursor buildDoc(File file, String[] projection) {
        final MatrixCursor cursor = new MatrixCursor(
                projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);

        final MatrixCursor.RowBuilder row = cursor.newRow();

        row.add(DocumentsContract.Document.COLUMN_DOCUMENT_ID, file.getAbsolutePath());
        row.add(DocumentsContract.Document.COLUMN_DISPLAY_NAME, file.getName());
        row.add(DocumentsContract.Document.COLUMN_SIZE, file.length());
        row.add(DocumentsContract.Document.COLUMN_LAST_MODIFIED, file.lastModified());

        if (file.isDirectory()) {
            row.add(DocumentsContract.Document.COLUMN_MIME_TYPE,
                    DocumentsContract.Document.MIME_TYPE_DIR);
            row.add(DocumentsContract.Document.COLUMN_FLAGS,
                    DocumentsContract.Document.FLAG_DIR_SUPPORTS_CREATE
                            | DocumentsContract.Document.FLAG_SUPPORTS_DELETE
                            | DocumentsContract.Document.FLAG_SUPPORTS_WRITE);
        } else {
            row.add(DocumentsContract.Document.COLUMN_MIME_TYPE, getMimeType(file.getName()));
            row.add(DocumentsContract.Document.COLUMN_FLAGS,
                    DocumentsContract.Document.FLAG_SUPPORTS_DELETE
                            | DocumentsContract.Document.FLAG_SUPPORTS_WRITE);
        }

        return cursor;
    }

    @Override
    public Cursor queryDocument(String documentId, String[] projection)
            throws FileNotFoundException {
        File file = new File(documentId);
        return buildDoc(file, projection);
    }

    @Override
    public Cursor queryChildDocuments(String parentDocumentId, String[] projection,
                                      String sortOrder) throws FileNotFoundException {
        File parent = new File(parentDocumentId);
        File[] children = parent.listFiles();

        final MatrixCursor cursor = new MatrixCursor(
                projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);

        if (children != null) {
            for (File file : children) {
                MatrixCursor.RowBuilder row = cursor.newRow();
                row.add(DocumentsContract.Document.COLUMN_DOCUMENT_ID, file.getAbsolutePath());
                row.add(DocumentsContract.Document.COLUMN_DISPLAY_NAME, file.getName());
                row.add(DocumentsContract.Document.COLUMN_SIZE, file.length());
                row.add(DocumentsContract.Document.COLUMN_LAST_MODIFIED, file.lastModified());

                if (file.isDirectory()) {
                    row.add(DocumentsContract.Document.COLUMN_MIME_TYPE,
                            DocumentsContract.Document.MIME_TYPE_DIR);
                    row.add(DocumentsContract.Document.COLUMN_FLAGS,
                            DocumentsContract.Document.FLAG_DIR_SUPPORTS_CREATE
                                    | DocumentsContract.Document.FLAG_SUPPORTS_DELETE
                                    | DocumentsContract.Document.FLAG_SUPPORTS_WRITE);
                } else {
                    row.add(DocumentsContract.Document.COLUMN_MIME_TYPE,
                            getMimeType(file.getName()));
                    row.add(DocumentsContract.Document.COLUMN_FLAGS,
                            DocumentsContract.Document.FLAG_SUPPORTS_DELETE
                                    | DocumentsContract.Document.FLAG_SUPPORTS_WRITE);
                }
            }
        }
        return cursor;
    }

    @Override
    public AssetFileDescriptor openDocument(String documentId, String mode)
            throws FileNotFoundException {
        File file = new File(documentId);
        ParcelFileDescriptor pfd = ParcelFileDescriptor.open(
                file, ParcelFileDescriptor.parseMode(mode));
        return new AssetFileDescriptor(pfd, 0, file.length());
    }

    @Override
    public ParcelFileDescriptor openDocumentThumbnail(String documentId, Point size,
                                                      CancellationSignal signal)
            throws FileNotFoundException {
        return openDocument(documentId, "r").getParcelFileDescriptor();
    }

    @Override
    public void deleteDocument(String documentId) throws FileNotFoundException {
        File file = new File(documentId);
        if (!file.delete())
            throw new FileNotFoundException("Unable to delete " + documentId);
    }

    @Override
    public String createDocument(String parentDocumentId, String mimeType, String displayName)
            throws FileNotFoundException {

        File parent = new File(parentDocumentId);
        File newFile = new File(parent, displayName);

        try {
            if (mimeType.equals(DocumentsContract.Document.MIME_TYPE_DIR)) {
                newFile.mkdirs();
            } else {
                newFile.createNewFile();
            }
        } catch (Exception e) {
            throw new FileNotFoundException("Create failed: " + e);
        }

        return newFile.getAbsolutePath();
    }
}