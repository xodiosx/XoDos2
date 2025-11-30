package com.com.xodos.filepicker;

import android.annotation.TargetApi;
import android.content.ContentValues;
import android.content.res.AssetFileDescriptor;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.os.Build;
import android.os.CancellationSignal;
import android.os.ParcelFileDescriptor;
import android.provider.DocumentsContract;
import android.provider.DocumentsProvider;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

@TargetApi(Build.VERSION_CODES.KITKAT)
public class XDocumentsProvider extends DocumentsProvider {

private static final String[] DEFAULT_ROOT_PROJECTION = new String[]{
        DocumentsContract.Root.COLUMN_ROOT_ID,
        DocumentsContract.Root.COLUMN_TITLE,
        DocumentsContract.Root.COLUMN_FLAGS,
        DocumentsContract.Root.COLUMN_DOCUMENT_ID,
        DocumentsContract.Root.COLUMN_ICON,
        DocumentsContract.Root.COLUMN_AVAILABLE_BYTES
};

private static final String[] DEFAULT_DOCUMENT_PROJECTION = new String[]{
        DocumentsContract.Document.COLUMN_DOCUMENT_ID,
        DocumentsContract.Document.COLUMN_DISPLAY_NAME,
        DocumentsContract.Document.COLUMN_SIZE,
        DocumentsContract.Document.COLUMN_MIME_TYPE,
        DocumentsContract.Document.COLUMN_LAST_MODIFIED,
        DocumentsContract.Document.COLUMN_FLAGS
};

@Override
public boolean onCreate() {
    return true;
}

@Override
public Cursor queryRoots(String[] projection) {
    MatrixCursor result = new MatrixCursor(projection != null ? projection : DEFAULT_ROOT_PROJECTION);
    MatrixCursor.RowBuilder row = result.newRow();

    row.add(DocumentsContract.Root.COLUMN_ROOT_ID, "home");
    row.add(DocumentsContract.Root.COLUMN_DOCUMENT_ID, "home");
    row.add(DocumentsContract.Root.COLUMN_TITLE, "XoDos App Data");
    row.add(DocumentsContract.Root.COLUMN_FLAGS, DocumentsContract.Root.FLAG_SUPPORTS_CREATE);
    row.add(DocumentsContract.Root.COLUMN_ICON, android.R.drawable.ic_menu_manage);

    File home = getContext().getFilesDir();
    row.add(DocumentsContract.Root.COLUMN_AVAILABLE_BYTES, home.getUsableSpace());

    return result;
}

@Override
public Cursor queryChildDocuments(String parentDocumentId, String[] projection, String sortOrder) throws FileNotFoundException {
    MatrixCursor result = new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
    File parent = getFileForDocId(parentDocumentId);

    File[] files = parent.listFiles();
    if (files != null) {
        for (File file : files) {
            includeFile(result, file);
        }
    }
    return result;
}

@Override
public ParcelFileDescriptor openDocument(String documentId, String mode, CancellationSignal signal) throws FileNotFoundException {
    File file = getFileForDocId(documentId);
    int accessMode = ParcelFileDescriptor.MODE_READ_ONLY;
    if (mode.contains("w")) accessMode = ParcelFileDescriptor.MODE_WRITE_ONLY | ParcelFileDescriptor.MODE_TRUNCATE;
    if (mode.contains("rw")) accessMode = ParcelFileDescriptor.MODE_READ_WRITE;
    return ParcelFileDescriptor.open(file, accessMode);
}

@Override
public void deleteDocument(String documentId) throws FileNotFoundException {
    File file = getFileForDocId(documentId);
    if (!file.delete()) throw new FileNotFoundException("Failed to delete: " + documentId);
}

@Override
public String createDocument(String parentDocumentId, String mimeType, String displayName) throws FileNotFoundException {
    File parent = getFileForDocId(parentDocumentId);
    File newFile = new File(parent, displayName);
    try {
        if ("application/octet-stream".equals(mimeType)) {
            if (!newFile.createNewFile()) throw new IOException("Failed to create file");
        } else {
            if (!newFile.mkdir()) throw new IOException("Failed to create folder");
        }
    } catch (IOException e) {
        throw new FileNotFoundException(e.getMessage());
    }
    return getDocIdForFile(newFile);
}

@Override
public String renameDocument(String documentId, String displayName) throws FileNotFoundException {
    File file = getFileForDocId(documentId);
    File renamed = new File(file.getParentFile(), displayName);
    if (!file.renameTo(renamed)) throw new FileNotFoundException("Failed to rename file");
    return getDocIdForFile(renamed);
}

@Override
public String getDocumentType(String documentId) throws FileNotFoundException {
    File file = getFileForDocId(documentId);
    if (file.isDirectory()) return DocumentsContract.Document.MIME_TYPE_DIR;
    String ext = MimeTypeMap.getFileExtensionFromUrl(file.getName());
    String mime = ext != null ? MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext) : null;
    return mime != null ? mime : "application/octet-stream";
}

@Override
public Cursor queryDocument(String documentId, String[] projection) throws FileNotFoundException {
    MatrixCursor result = new MatrixCursor(projection != null ? projection : DEFAULT_DOCUMENT_PROJECTION);
    includeFile(result, getFileForDocId(documentId));
    return result;
}

/** New: Support changing permissions */
//@Override
public void updateDocument(String documentId, ContentValues values) throws FileNotFoundException {
    File file = getFileForDocId(documentId);
    if (values.containsKey("chmod")) {
        String mode = values.getAsString("chmod");
        applyChmod(file, mode);
    }
    if (values.containsKey("executable")) {
        boolean exec = values.getAsBoolean("executable");
        file.setExecutable(exec, false);
    }
    if (values.containsKey("readable")) {
        boolean read = values.getAsBoolean("readable");
        file.setReadable(read, false);
    }
    if (values.containsKey("writable")) {
        boolean write = values.getAsBoolean("writable");
        file.setWritable(write, false);
    }
}

private void applyChmod(File file, String mode) {
    if (mode.length() != 3) return;
    try {
        int owner = Character.getNumericValue(mode.charAt(0));
        int group = Character.getNumericValue(mode.charAt(1));
        int other = Character.getNumericValue(mode.charAt(2));

        file.setReadable((owner & 4) != 0, true);
        file.setWritable((owner & 2) != 0, true);
        file.setExecutable((owner & 1) != 0, true);

        file.setReadable((group & 4) != 0, false);
        file.setWritable((group & 2) != 0, false);
        file.setExecutable((group & 1) != 0, false);

        file.setReadable((other & 4) != 0, false);
        file.setWritable((other & 2) != 0, false);
        file.setExecutable((other & 1) != 0, false);

    } catch (Exception ignored) {}
}

/** Helper Methods **/

private void includeFile(MatrixCursor result, File file) {
    MatrixCursor.RowBuilder row = result.newRow();
    row.add(DocumentsContract.Document.COLUMN_DOCUMENT_ID, getDocIdForFile(file));
    row.add(DocumentsContract.Document.COLUMN_DISPLAY_NAME, file.getName());
    row.add(DocumentsContract.Document.COLUMN_SIZE, file.isFile() ? file.length() : 0);
    row.add(DocumentsContract.Document.COLUMN_MIME_TYPE, file.isDirectory() ? DocumentsContract.Document.MIME_TYPE_DIR : getMimeType(file));
    row.add(DocumentsContract.Document.COLUMN_LAST_MODIFIED, file.lastModified());
    int flags = DocumentsContract.Document.FLAG_SUPPORTS_DELETE
            | DocumentsContract.Document.FLAG_SUPPORTS_WRITE
            | DocumentsContract.Document.FLAG_SUPPORTS_RENAME;
    row.add(DocumentsContract.Document.COLUMN_FLAGS, flags);
}

private File getFileForDocId(String docId) {
    return new File(getContext().getFilesDir(), docId);
}

private String getDocIdForFile(File file) {
    return file.getName();
}

private String getMimeType(File file) {
    if (file.isDirectory()) return DocumentsContract.Document.MIME_TYPE_DIR;
    String ext = MimeTypeMap.getFileExtensionFromUrl(file.getName());
    String mime = ext != null ? MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext) : null;
    return mime != null ? mime : "application/octet-stream";
}

}