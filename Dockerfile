FROM sagemath/sagemath:9.5

# added sed command to avoid Ubuntu impish "end of life" warnings
RUN sudo sed -i -e 's|impish|jammy|g' /etc/apt/sources.list; yes | sudo apt update; yes | sudo apt-get upgrade; yes | sudo DEBIAN_FRONTEND=noninteractive apt install curl wget build-essential python3-urllib3;

RUN GAP_INSTALL_DIR=`sudo find / -name "GAPDoc*" | head -n 1 | xargs dirname`; \
	\
	curl -L https://github.com/gap-packages/numericalsgps/releases/download/v1.2.1/NumericalSgps-1.2.1.tar.gz --output "${GAP_INSTALL_DIR}/NumericalSgps.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/NumericalSgps.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	\
	curl -L https://github.com/gap-packages/singular/releases/download/v2022.09.23/singular-2022.09.23.tar.gz --output "${GAP_INSTALL_DIR}/singular-2022.09.23.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/singular-2022.09.23.tar.gz" -C "${GAP_INSTALL_DIR}";

RUN cd /home/sage/sage && wget https://raw.githubusercontent.com/sagemath/sage/develop/configure.ac;

RUN sage -p 4ti2

RUN sage -p topcom

RUN sage -p nauty

RUN sage -p e_antic

RUN sage -p normaliz
RUN sage -p pynormaliz

# the backend fails to build, seems for a long time now
# RUN sage -p cbc
# RUN sage -pip install sage-numerical-backends-coin

RUN sage -c "gap_reset_workspace()"

RUN sudo curl https://raw.githubusercontent.com/coneill-math/numsgps-sage/master/NumericalSemigroup.sage --output "/NumericalSemigroup.sage"

RUN sudo curl https://raw.githubusercontent.com/coneill-math/kunzpolyhedron/master/KunzPoset.sage --output "/KunzPoset.sage"
RUN sudo curl https://raw.githubusercontent.com/coneill-math/kunzpolyhedron/master/PlotKunzPoset.sage --output "/PlotKunzPoset.sage"
RUN sudo curl https://raw.githubusercontent.com/coneill-math/kunzpolyhedron/master/PlotKunzPoset3D.sage --output "/PlotKunzPoset3D.sage"




# Setting up Macaulay2 repository
RUN sudo apt-get update && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends software-properties-common apt-transport-https && \
    sudo add-apt-repository ppa:macaulay2/macaulay2 && sudo add-apt-repository ppa:macaulay2/macaulay2 && \
    sudo apt-get update && sudo apt-get clean

# Install Macaulay2
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends macaulay2 && sudo apt-get clean

# Install optional packages
# RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y emacs elpa-macaulay2 bash-completion curl git mlocate && \
#     sudo apt-get clean && updatedb

# Add non-root user for running Macaulay2
# RUN useradd -G sudo -g root -u 1000 -m macaulay && echo "macaulay ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# USER 1000:0

# Setting environment variables
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/lib/Macaulay2/lib"
ENV PATH "${PATH}:/usr/libexec/Macaulay2/bin"

# WORKDIR /home/macaulay
# ENTRYPOINT emacs


# add M2 to Jupyter
RUN sage --pip install macaulay2-jupyter-kernel
RUN sage --python3 -m m2_kernel.install

# make horizontal scrolling work
RUN echo "div.output_subarea pre { white-space: pre }" >> /home/sage/sage/local/var/lib/sage/venv-python3.9.9/lib/python3.9/site-packages/notebook/static/custom/custom.css

# increase M2 timeout (default was 4 seconds, *way* too short)
RUN curl -L https://raw.githubusercontent.com/coneill-math/macaulay2-jupyter-kernel/master/m2_kernel/kernel.py --output /home/sage/sage/local/var/lib/sage/venv-python3.9.9/lib/python3.9/site-packages/m2_kernel/kernel.py


# install RISE for slideshows
RUN sage --pip install RISE



