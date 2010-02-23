import os
import glob
import shutil
import re


# Settings
# TODO: make it linux friendly too.
VIMF_DIR = os.path.expanduser("~/vimfiles/")
SRC_DIR = os.path.expanduser("../src/")


def get_vimwiki_files(vw_from, vw_to, process_file=None):
    """Copy vimwiki files from 'vw_from' to 'vw_to' dir.
    Run 'process_file' on all copied files.
    """
    for file in glob.glob(os.path.normpath(vw_from + "**/vimwiki*")):
        dir = os.path.dirname(file).split(os.sep)[-1]
        dir = os.path.join(vw_to, dir)
        try:
            os.makedirs(dir)
        except:
            pass

        shutil.copy(file, dir)
        if process_file:
            process_file(os.path.join(dir, os.path.basename(file)))


def set_ff_unix(vw_file):
    """Set unix line endings."""
    fname_tmp = vw_file + ".#tmp#"
    with open(fname_tmp, "w", newline='\n') as file_to, \
            open(vw_file, "r") as file_from:
        for line in file_from:
            file_to.write(line.rstrip('\r\n') + '\n')
    os.remove(vw_file)
    os.rename(fname_tmp, vw_file)


if __name__ == "__main__":
    print("Getting vimwiki files into {}".format(SRC_DIR))
    get_vimwiki_files(VIMF_DIR, SRC_DIR, set_ff_unix)
