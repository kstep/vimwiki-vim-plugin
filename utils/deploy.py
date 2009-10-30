"""
Vimwiki deployment script.
    * Copy vimwiki's files from vim runtime path into SRC_DIR directory.
    * Change CRLFs to LFs of every copied file.
    * Make Vimball archive (vba) file in DEPLOY_DIR directory.
    * Zip vimwiki files into 'DEPLOY_DIR/vimwiki_{VERSION}.zip'
    * Zip vba file into 'DEPLOY_DIR/vimwiki_{VERSION}_vba.zip'
    * gz vba file into 'DEPLOY_DIR/vimwiki_{VERSION}.vba.gz'
"""

from __future__ import print_function
import os
import glob
import shutil
import re

import zipfile
import gzip

import mkvimball as vba


# Settings
# TODO: get version from the vimwiki help file
VIMF_DIR = os.path.expanduser("~/vimfiles/")
DEPLOY_DIR = os.path.expanduser("~/work/vimwiki/deploy/")
SRC_DIR = os.path.expanduser("~/work/vimwiki/src/")


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

def get_vimwiki_version():
    with open(SRC_DIR + 'doc/vimwiki.txt') as f:
        for line in f:
            r = re.search('Version:\s*(\S*)', line)
            if r:
                return r.groups()[0]

def make_vba_file(src_dir, vba_file_name):
    try:
        os.makedirs(os.path.dirname(vba_file_name))
    except:
        pass

    inc_names = []
    for file in glob.glob(os.path.join(src_dir, "**/*")):
        file = os.path.normpath(file)
        file = os.sep.join(file.split(os.sep)[-2:])
        inc_names.append(file)
    vba.mk_vimball(src_dir, inc_names, vba_file_name)


def set_ff_unix(vw_file):
    """Set unix line endings."""
    fname_tmp = vw_file + ".#tmp#"
    with open(fname_tmp, "w", newline='\n') as file_to:
        with open(vw_file, "r") as file_from:
            for line in file_from:
                file_to.write(line.rstrip('\r\n') + '\n')
    os.remove(vw_file)
    os.rename(fname_tmp, vw_file)


def make_zip_folder(folder, arcname):
    try:
        os.makedirs(os.path.dirname(arcname))
    except:
        pass

    arc = zipfile.ZipFile(arcname, "w")
    for file in glob.glob(os.path.join(folder, "*", "*")):
        afile = os.path.normpath(file)
        afile = os.sep.join(afile.split(os.sep)[-2:])
        arc.write(file, afile, zipfile.ZIP_DEFLATED)
    arc.close()


def make_zip_vba(vba_name, zip_vba_name):
    arc = zipfile.ZipFile(zip_vba_name, "w", zipfile.ZIP_DEFLATED)
    arc.write(os.path.join(DEPLOY_DIR, vba_name), vba_name)
    arc.close()


def make_gzip_vba(vba_name, full_vba_name):
    f_in = open(full_vba_name, 'rb')
    f = open(full_vba_name+'.gz', 'wb')
    f_gzout = gzip.GzipFile(vba_name, 'wb', 9, f)
    f_gzout.writelines(f_in)
    f_in.close()
    f_gzout.close()
    f.close()


if __name__ == "__main__":
    print("Getting vimwiki files into {}".format(SRC_DIR))
    get_vimwiki_files(VIMF_DIR, SRC_DIR, set_ff_unix)

    ver = get_vimwiki_version().replace('.', '_')
    print("Getting vimwiki version: {}".format(ver))

    vba_name = "vimwiki_{0}.vba".format(ver)
    path_vba_name = os.path.join(DEPLOY_DIR, vba_name)
    print("Creating vba file: {}".format(path_vba_name))
    make_vba_file(SRC_DIR, path_vba_name)

    zip_name = "vimwiki_{0}.zip".format(ver)
    path_zip_name = os.path.join(DEPLOY_DIR, zip_name)
    print("Packing src files into: {}".format(path_zip_name))
    make_zip_folder(SRC_DIR, path_zip_name)

    zip_vba_name = "vimwiki_{0}_vba.zip".format(ver)
    path_zip_vba_name = os.path.join(DEPLOY_DIR, zip_vba_name)
    print("Packing vba file into: {}".format(path_zip_vba_name))
    make_zip_vba(vba_name, path_zip_vba_name)

    print("Packing vba file into: {}".format(path_vba_name+".gz"))
    make_gzip_vba(vba_name, path_vba_name)
