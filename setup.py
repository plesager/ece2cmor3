import os
from setuptools import setup, find_packages
import distutils.command.build_py
from ece2cmor3 import __version__

name = "ece2cmor3"


# Utility function to read the README file.
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()


# Utility function to get the git hash, possibly with local changes flag
def get_git_hash():
    import git
    repo = git.Repo(search_parent_directories=True)
    sha = str(repo.head.object.hexsha)
    if repo.is_dirty():
        sha += "-changes"
    return sha


# Overriden build command, appending git hash to version python file
class add_sha(distutils.command.build_py.build_py):

    def run(self):
        distutils.command.build_py.build_py.run(self)
        if not self.dry_run:
            filepath = os.path.join(self.build_lib, name, "__version__.py")
            with open(filepath, "a") as version_file:
                version_file.write("sha = \"{hash}\"\n".format(hash=get_git_hash()))


setup(name=name,
      version=__version__.version,
      author="Gijs van den Oord",
      author_email="g.vandenoord@esciencecenter.nl",
      description="CMORize and post-process EC-Earth output data",
      license="Apache License, Version 2.0",
      url="https://github.com/EC-Earth/ece2cmor3",
      packages=find_packages(exclude=("tests", "examples")),
      package_data={"ece2cmor3": ["resources/*.json",
                                  "resources/*.xlsx",
                                  "resources/*.txt",
                                  "resources/tables/*.json",
                                  "resources/metadata-templates/*.json",
                                  "resources/lists-of-omitted-variables/*.xlsx"]},
      include_package_data=True,
      long_description=read("README.md"),
      entry_points={"console_scripts": [
          "ece2cmor =  ece2cmor3.ece2cmor:main",
          "checkvars =  ece2cmor3.scripts.checkvars:main",
          "drq2ppt =  ece2cmor3.scripts.drq2ppt:main",
          "fixmonths =  ece2cmor3.scripts.fixmonths:main",
          "splitbalance =  ece2cmor3.scripts.splitbalance:main"
      ]},
      classifiers=[
          "Development Status :: 3 - Alpha",
          "Intended Audience :: Science/Research",
          "Programming Language :: Python",
          "Operating System :: OS Independent",
          "Topic :: Scientific/Engineering :: Atmospheric Science",
          "License :: OSI Approved :: Apache Software License"
      ],
      cmdclass={"build_py": add_sha}
      )
