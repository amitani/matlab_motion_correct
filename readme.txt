Motion correction scripts.
	Akinori Mitani (2017)
	amitani.tky@gmail.com

If used for research, please properly cite a paper this is used first and mention it in Methods.
Brain-Computer Interface with Inhibitory Neurons Reveals Subtype-Specific Strategies
Mitani, Akinori et al. Current Biology , Volume 28 , Issue 1 , 77 - 83.e4
http://www.cell.com/current-biology/fulltext/S0960-9822(17)31517-8

batch_motion_correct_dir processes all the tif files in a directory.

batch_motion_correct_queued is similar but takes file lists as an arguments.

motion_correct processes one file.

motion_correct.xml can specify parameters for OpenCV based motion correction. The file here is used as default. Put one file to the same directory as processing files and the parameters can be set specifically for those files (see load_mc_settings_from_xml.m)
If there is no motion_correct.xml files (either here or at where the files are), mexBilinearRegistrator is used. This is gradient-based method which can converge to a local minimum. In some situatons this can potentially work better. @BilinearPyramidImageRegistrator uses the same algorithm to mexBilinearRegistrator written solely in Matlab.

By default, this uses the last channel for alignment (assuming red is structural if used) and save the first channel (assuming GCaMP in green ch)

All the mex files are compiled for Windows 64 bit environment with VC++ runtime. Run vcredist_x64.exe to install it.
To compile mex files, OpenCV with Matlab support is required.
Also, they anly take int16 inputs. If your data is not in this format, convert it or use Matlab version (@BilinearPyramidImageRegistrator).

Source code for the mex files is shared in another repository (https://github.com/amitani/mex_tools).





