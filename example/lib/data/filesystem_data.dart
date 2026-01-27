import 'package:flutter_folderview/flutter_folderview.dart';

List<Node<String>> getFileSystemData() {
  // Documents
  const documents = Node<String>(
    id: 'fs_documents',
    label: 'Documents',
    type: NodeType.parent,
    children: [
      Node<String>(id: 'fs_doc_1', label: 'resume.pdf', type: NodeType.child),
      Node<String>(
        id: 'fs_doc_2',
        label: 'cover_letter.docx',
        type: NodeType.child,
      ),
      Node<String>(
        id: 'fs_doc_3',
        label: 'presentation.pptx',
        type: NodeType.child,
      ),
    ],
  );

  // Pictures
  const pictures = Node<String>(
    id: 'fs_pictures',
    label: 'Pictures',
    type: NodeType.parent,
    children: [
      Node<String>(id: 'fs_pic_1', label: 'vacation.jpg', type: NodeType.child),
      Node<String>(id: 'fs_pic_2', label: 'profile.png', type: NodeType.child),
    ],
  );

  // Downloads
  const downloads = Node<String>(
    id: 'fs_downloads',
    label: 'Downloads',
    type: NodeType.parent,
    children: [
      Node<String>(id: 'fs_dl_1', label: 'installer.exe', type: NodeType.child),
      Node<String>(id: 'fs_dl_2', label: 'archive.zip', type: NodeType.child),
      Node<String>(id: 'fs_dl_3', label: 'readme.txt', type: NodeType.child),
    ],
  );

  // Projects
  const projects = Node<String>(
    id: 'fs_projects',
    label: 'Projects',
    type: NodeType.parent,
    children: [
      Node<String>(id: 'fs_proj_1', label: 'flutter_app', type: NodeType.child),
      Node<String>(id: 'fs_proj_2', label: 'website', type: NodeType.child),
    ],
  );

  return [documents, pictures, downloads, projects];
}
