FROM coneillmath/sage
WORKDIR /home/sage

# added sed command to avoid Ubuntu impish "end of life" warnings
RUN sudo apt update && \
	sudo apt-get upgrade -y && \
	sudo apt-get install -y curl wget build-essential python3-urllib3 && \
    sudo apt-get update && \
    sudo apt-get clean

# Setting up Macaulay2 repository
# the following is mostly pulled from the Macaulay2 Dockerfile
ENV DEBIAN_FRONTEND=noninteractive

RUN sudo apt-get update && \
    sudo apt-get install -y software-properties-common apt-transport-https gnupg && \
    sudo add-apt-repository -y ppa:macaulay2/macaulay2 && \
    sudo apt-get update && \
    sudo apt-get clean

# install normaliz
# the following is pulled from the normaliz Dockerfile

RUN sudo apt-get update \
    && sudo apt-get install -y \
    build-essential m4 \
    autoconf autogen libtool \
    libgmp-dev \
    git \
    libboost-all-dev \
    wget curl sed \
    unzip \
    sudo \
    python3-pip
RUN pip3 install setuptools

RUN sudo apt-get install -y normaliz

# install Macaulay2
# the following is mostly pulled from the Macaulay2 Dockerfile
RUN sudo apt-get install -y locate bash-completion && sudo apt-get clean && sudo updatedb

RUN sudo apt-get install -y macaulay2 && sudo apt-get clean

# Setting environment variables
ENV LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:/usr/lib/Macaulay2/lib"
ENV PATH="${PATH}:/usr/libexec/Macaulay2/bin"

RUN GAP_INSTALL_DIR=`sudo find / -name "GAPDoc*" | head -n 1 | xargs dirname`/../..; \
	\
	curl -L https://github.com/gap-packages/numericalsgps/releases/download/v1.4.0/NumericalSgps-1.4.0.tar.gz --output "${GAP_INSTALL_DIR}/NumericalSgps.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/NumericalSgps.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	\
	curl -L https://github.com/gap-packages/singular/releases/download/v2022.09.23/singular-2022.09.23.tar.gz --output "${GAP_INSTALL_DIR}/singular-2022.09.23.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/singular-2022.09.23.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	\
	sudo apt-get install -y graphviz; \
	curl -L https://github.com/gap-packages/io/releases/download/v4.9.1/io-4.9.1.tar.gz --output "${GAP_INSTALL_DIR}/io.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/io.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	cd "/home/sage/sage/local/lib/gap/pkg/io-4.9.1" && ./configure && make; \
	\
	curl -L https://github.com/gap-packages/json/releases/download/v2.2.2/json-2.2.2.tar.gz --output "${GAP_INSTALL_DIR}/json.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/json.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	cd "/home/sage/sage/local/lib/gap/pkg/json-2.2.2" && ./configure && make; \
	\
	curl -L https://github.com/gap-packages/uuid/releases/download/v0.7/uuid-0.7.tar.gz --output "${GAP_INSTALL_DIR}/uuid.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/uuid.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	\
	sudo apt-get install -y libzmq3-dev; \
	curl -L https://github.com/gap-packages/ZeroMQInterface/releases/download/v0.16/ZeroMQInterface-0.16.tar.gz --output "${GAP_INSTALL_DIR}/ZeroMQInterface.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/ZeroMQInterface.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	cd "/home/sage/sage/local/lib/gap/pkg/ZeroMQInterface-0.16" && ./configure && make; \
	\
	curl -L https://github.com/gap-packages/crypting/releases/download/v0.10.5/crypting-0.10.5.tar.gz --output "${GAP_INSTALL_DIR}/crypting.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/crypting.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	cd "/home/sage/sage/local/lib/gap/pkg/crypting-0.10.5" && ./configure && make; \
	\
	curl -L https://github.com/gap-packages/JupyterKernel/releases/download/v1.5.1/JupyterKernel-1.5.1.tar.gz --output "${GAP_INSTALL_DIR}/JupyterKernel.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/JupyterKernel.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	cd /home/sage
ENV PATH="${PATH}:/home/sage/sage/local/lib/gap/pkg/JupyterKernel/bin"

RUN sage -c "gap_reset_workspace()"

# add gap to Jupyter
RUN cd "/home/sage/sage/local/lib/gap/pkg/JupyterKernel-1.5.1" && \
	sage -pip install . && \
	cd /home/sage

RUN sudo curl https://raw.githubusercontent.com/coneill-math/numsgps-sage/master/NumericalSemigroup.sage --output "/NumericalSemigroup.sage"
RUN sudo curl https://raw.githubusercontent.com/coneill-math/kunzpolyhedron/master/KunzPoset.sage --output "/KunzPoset.sage"
RUN sudo curl https://raw.githubusercontent.com/coneill-math/kunzpolyhedron/master/PlotKunzPoset.sage --output "/PlotKunzPoset.sage"
RUN sudo curl https://raw.githubusercontent.com/coneill-math/kunzpolyhedron/master/PlotKunzPoset3D.sage --output "/PlotKunzPoset3D.sage"

RUN cd /home/sage/sage && wget https://raw.githubusercontent.com/sagemath/sage/develop/configure.ac;

RUN sudo apt-get install -y 4ti2 topcom libnauty-dev libeantic-dev

# RUN sage -p pynormaliz
# in the future, may need to specify version for given normaliz version
RUN sage -pip install pynormaliz

# add M2 to Jupyter
RUN git clone https://github.com/coneill-math/macaulay2-jupyter-kernel.git && \
    cd macaulay2-jupyter-kernel && \
    sage -pip install . && \
    sage --python3 -m m2_kernel.install && \
    cd .. \
    rm -rf macaulay2-jupyter-kernel

# install RISE for slideshows
RUN sage --pip install RISE


# make horizontal scrolling work
# no longer needed as this is default in Jupyter 7
# RUN echo "div.output_subarea pre { white-space: pre }" >> /home/sage/sage/local/var/lib/sage/venv-python3.9.9/lib/python3.9/site-packages/notebook/static/custom/custom.css

# increase M2 timeout (default was 4 seconds, *way* too short)
# no longer needed since we install our custom version of the kernel anyway
# RUN curl -L https://raw.githubusercontent.com/coneill-math/macaulay2-jupyter-kernel/master/m2_kernel/kernel.py --output /home/sage/sage/local/var/lib/sage/venv-python3.9.9/lib/python3.9/site-packages/m2_kernel/kernel.py

# install normaliz from source - mostly pulled from the normaliz Dockerfile
# RUN git clone https://github.com/Normaliz/Normaliz.git && \
#     cd Normaliz && \
#     git checkout master && \
#     cd ..
# 
# RUN   sudo chown -R sage:sage Normaliz && \
#     cd Normaliz && \
#     ./install_normaliz_with_eantic.sh &&\
#     sudo cp -r local /usr &&\
#     sudo ldconfig && \
#     cd .. && \
# 	rm -rf Normaliz






