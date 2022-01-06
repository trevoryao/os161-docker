FROM ubuntu:14.04

# extra packages
RUN apt-get -y update && \
    apt-get -y install gettext \
        libncurses5-dev \
        wget \
        make \
        git

WORKDIR /tmp

RUN wget --no-check-certificate -q https://ftp.gnu.org/gnu/texinfo/texinfo-4.13.tar.gz && \
    tar -xzf texinfo-4.13.tar.gz && \
    cd texinfo-4.13 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf texinfo-4.13 && \
    rm texinfo-4.13.tar.gz

RUN useradd -ms /bin/bash user && \
    usermod -G root user

ENV INSTALL_DIR=/home/user/sys161

# step 1: download necessary files
ENV FILES='os161-binutils.tar.gz os161-gcc.tar.gz os161-gdb.tar.gz os161-bmake.tar.gz os161-mk.tar.gz sys161.tar.gz '
RUN for f in $FILES; do \
        wget --no-check-certificate -q http://www.student.cs.uwaterloo.ca/~cs350/os161_repository/$f && \
        tar -xzf $f; \
    done

# step 2: binutils
RUN cd binutils-2.17+os161-2.0.1 && \
    ./configure --nfp --disable-werror --target=mips-harvard-os161 --prefix=$INSTALL_DIR/tools && \
    make && \
    make install

# step 3: change path & bashrc config
RUN mkdir -p $INSTALL_DIR/bin

# location of bash script to be run before user profile is configured
ARG BASHRC_CONFIG_SCRIPT=./bashrc_config.sh

COPY $BASHRC_CONFIG_SCRIPT /tmp
RUN if [ ! -z $BASHRC_CONFIG_SCRIPT ]; then \
    chmod u+x $BASHRC_CONFIG_SCRIPT && $BASHRC_CONFIG_SCRIPT && rm $BASHRC_CONFIG_SCRIPT; \
fi

COPY .bashrc /home/user/.bashrc
RUN echo 'export PATH=$INSTALL_DIR/bin:$INSTALL_DIR/tools/bin:$PATH' >> /home/user/.bashrc

# step 4: gcc
RUN export PATH=$INSTALL_DIR/bin:$INSTALL_DIR/tools/bin:$PATH && \
    cd gcc-4.1.2+os161-2.0 && \
    ./configure -nfp --disable-shared --disable-threads --disable-libmudflap --disable-libssp --target=mips-harvard-os161 --prefix=$INSTALL_DIR/tools && \
    make && \
    make install

# step 5: gdb
RUN export PATH=$INSTALL_DIR/bin:$INSTALL_DIR/tools/bin:$PATH && \
    cd gdb-6.6+os161-2.0 && \
    ./configure --target=mips-harvard-os161 --disable-werror --prefix=$INSTALL_DIR/tools && \
    make && \
    make install

# step 6: bmake
RUN export PATH=$INSTALL_DIR/bin:$INSTALL_DIR/tools/bin:$PATH && \
    cd bmake && \
    tar -xzf ../os161-mk.tar.gz && \
    ./boot-strap --prefix=$INSTALL_DIR/tools && \
    mkdir -p /home/user/sys161/tools/bin && \
    cp /tmp/bmake/Linux/bmake /home/user/sys161/tools/bin/bmake-20101215 && \
    rm -f /home/user/sys161/tools/bin/bmake && \
    ln -s bmake-20101215 /home/user/sys161/tools/bin/bmake && \
    mkdir -p /home/user/sys161/tools/share/man/cat1 && \
    cp /tmp/bmake/bmake.cat1 /home/user/sys161/tools/share/man/cat1/bmake.1 && \
    sh /tmp/bmake/mk/install-mk /home/user/sys161/tools/share/mk

# step 7: links for toolchain binaries
RUN export PATH=$INSTALL_DIR/bin:$INSTALL_DIR/tools/bin:$PATH && \
    mkdir -p $INSTALL_DIR/bin && \
    cd $INSTALL_DIR/tools/bin && \
    sh -c 'for i in mips-*; do ln -s $INSTALL_DIR/tools/bin/$i $INSTALL_DIR/bin/cs350-`echo $i | cut -d- -f4-`; done' && \
    ln -s $INSTALL_DIR/tools/bin/bmake $INSTALL_DIR/bin/bmake

# step 8: sys161 simulator
RUN export PATH=$INSTALL_DIR/bin:$INSTALL_DIR/tools/bin:$PATH && \
    cd sys161-1.99.06 && \
    ./configure --prefix=$INSTALL_DIR mipseb && \
    make && \
    make install && \
    cd $INSTALL_DIR && \
    ln -s share/examples/sys161/sys161.conf.sample sys161.conf

# cleanup
RUN for f in $FILES; do rm -rf $f; done && \
    rm -rf binutils-2.17+os161-2.0.1 gcc-4.1.2+os161-2.0 gdb-6.6+os161-2.0 bmake sys161-1.99.06

WORKDIR /home/user

# ssh setup
ARG SSH_PATH=.ssh
COPY $SSH_PATH .ssh
RUN chown -R user:user /home/user/.ssh

# set up repo for project
USER user

ARG GIT_URL

WORKDIR $HOME
RUN if [ -z "$GIT_URL" ]; then git clone $GIT_URL; fi
