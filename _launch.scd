//~p.push;
File.open(PathName(Document.current.path).parentPath ++ "_main.scd", "r").readAllString.interpret;