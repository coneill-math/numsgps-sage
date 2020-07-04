FROM sagemath/sagemath
RUN yes | sudo apt update; yes | sudo apt-get upgrade; yes | sudo apt install curl

RUN GAP_INSTALL_DIR=`sudo find / -name "GAPDoc*" | head -n 1 | xargs dirname`; \
	\
	curl https://files.gap-system.org/gap4/tar.gz/packages/NumericalSgps-1.2.1.tar.gz --output "${GAP_INSTALL_DIR}/NumericalSgps-1.2.1.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/NumericalSgps-1.2.1.tar.gz" -C "${GAP_INSTALL_DIR}"; \
	\
	curl https://files.gap-system.org/gap4/tar.gz/packages/singular-2019.10.01.tar.gz --output "${GAP_INSTALL_DIR}/singular-2019.10.01.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/singular-2019.10.01.tar.gz" -C "${GAP_INSTALL_DIR}";
	\
	curl https://files.gap-system.org/gap4/tar.gz/packages/4ti2Interface-4ti2Interface-2019.09.02.tar.gz --output "${GAP_INSTALL_DIR}/4ti2Interface-4ti2Interface-2019.09.02.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/4ti2Interface-4ti2Interface-2019.09.02.tar.gz" -C "${GAP_INSTALL_DIR}";
	\
	curl https://files.gap-system.org/gap4/tar.gz/packages/NormalizInterface-1.1.0.tar.gz --output "${GAP_INSTALL_DIR}/NormalizInterface-1.1.0.tar.gz"; \
	tar -xvf "${GAP_INSTALL_DIR}/NormalizInterface-1.1.0.tar.gz" -C "${GAP_INSTALL_DIR}";

RUN sage -c "gap_reset_workspace()"

RUN sudo curl https://raw.githubusercontent.com/coneill-math/numsgps-sage/master/NumericalSemigroup.sage --output "/NumericalSemigroup.sage"


