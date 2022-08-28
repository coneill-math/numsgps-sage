FROM sagemath/sagemath

# added sed command to avoid Ubuntu impish "end of life" warnings
RUN sudo sed -i -e 's|impish|jammy|g' /etc/apt/sources.list; yes | sudo apt update; yes | sudo apt-get upgrade; yes | sudo DEBIAN_FRONTEND=noninteractive apt install curl wget build-essential python3-urllib3;

RUN GAP_INSTALL_DIR=`sudo find / -name "GAPDoc*" | head -n 1 | xargs dirname`; \
	\
	curl https://files.gap-system.org/gap4/tar.gz/packages/NumericalSgps-1.2.1.tar.gz --output "${GAP_INSTALL_DIR}/NumericalSgps-1.2.1.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/NumericalSgps-1.2.1.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	\
	curl https://files.gap-system.org/gap4/tar.gz/packages/singular-2019.10.01.tar.gz --output "${GAP_INSTALL_DIR}/singular-2019.10.01.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/singular-2019.10.01.tar.gz" -C "${GAP_INSTALL_DIR}";

RUN cd /home/sage/sage && wget https://github.com/sagemath/sage/blob/develop/configure.ac; sage -p 4ti2;

RUN sage -p nauty

RUN sage -p e_antic

RUN sage -p normaliz

RUN sage -p pynormaliz

RUN sage -c "gap_reset_workspace()"

RUN sudo curl https://raw.githubusercontent.com/coneill-math/numsgps-sage/master/NumericalSemigroup.sage --output "/NumericalSemigroup.sage"

RUN sudo curl https://raw.githubusercontent.com/coneill-math/kunzpolyhedron/master/KunzPoset.sage --output "/KunzPoset.sage"
RUN sudo curl https://raw.githubusercontent.com/coneill-math/kunzpolyhedron/master/PlotKunzPoset.sage --output "/PlotKunzPoset.sage"
RUN sudo curl https://raw.githubusercontent.com/coneill-math/kunzpolyhedron/master/PlotKunzPoset3D.sage --output "/PlotKunzPoset3D.sage"


