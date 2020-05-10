import 'dart:io';

File assetFile(String name) {
   var dir = Directory.current.path;
   if (dir.endsWith('/test')) {
     dir = dir.replaceAll('/test', '');
   }
   return File('$dir/assets/$name');
}
