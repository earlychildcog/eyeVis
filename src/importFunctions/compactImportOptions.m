function opts = compactImportOptions(path)


opts = detectImportOptions(path);
opts.VariableTypes = strrep(opts.VariableTypes, 'char', 'string');
opts.VariableTypes = strrep(opts.VariableTypes, 'double', 'single');