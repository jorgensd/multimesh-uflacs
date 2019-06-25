# This is a Dockerfile used to install the necessary dependencies for
# running the examples for Navier Stokes multimesh, using Magne Nordaas uflacs
# uflacs implementation of multimesh.
#
# Authors:
# Jørgen S. Dokken <dokken92@gmail.com>

FROM quay.io/fenicsproject/dev-env:2018.1.0

USER fenics
ENV GMSH_VER=3.0.6
COPY dependencies.conf $FENICS_HOME/dependencies.conf
ENV IPOPT_VER=3.12.9
COPY dolfin-adjoint.conf $FENICS_HOME/dolfin-adjoint.conf

COPY fenics_pull /home/fenics/fenics_pull
COPY fenics_build /home/fenics/fenics_build

USER root
RUn apt-get update && \
apt-get install -y libgl1-mesa-glx libxcursor1 libxft2 libxinerama1 libglu1-mesa imagemagick python3-h5py python3-lxml && \
apt-get clean

RUN /bin/bash -l -c "/home/fenics/fenics_pull"
RUN /bin/bash -l -c "/home/fenics/fenics_build fiat dijitso ufl ffc dolfin"

RUN /bin/bash -l -c "source $FENICS_HOME/dependencies.conf &&\
                     install_gmsh && \
                     update_ipopt && \
                     update_pyipopt"

RUN /bin/bash -l -c "apt-get install -y graphviz graphviz-dev &&\
	   	      	     pip3 install pygraphviz &&\
			     pip3 install pygmsh==4.4.0 meshio moola jdc tabulate"

RUN /bin/bash -l -c "apt purge -y python2.7-minimal"

USER fenics
RUN echo 'alias python="python3"' >> $FENICS_HOME/.bashrc
RUN echo "source $FENICS_HOME/dependencies.conf" >> $FENICS_HOME/.bash_profile
RUN /bin/bash -l -c "python3 -c \"import dolfin\""
RUN /bin/bash -l -c "gmsh -version"

COPY WELCOME $FENICS_HOME/WELCOME

USER root
