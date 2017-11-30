function fn_r = fn_root(fn)
 [PATHSTR,NAME] = fileparts(fn);
 fn_r = fullfile(PATHSTR,NAME);
end