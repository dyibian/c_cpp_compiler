build_sdktools() {
    PKG=sdktools
    PKG_VERSION=1.1
    PKG_DESC="android sdk tools"
    O_DIR=${TOPDIR}/misc/sdktools
    B_DIR=${build_dir}/${PKG}

    c_tag ${PKG} && return

    banner "Build $PKG"

    preparesrc $O_DIR $B_DIR

    cd $B_DIR

    local OPTS
    case $TARGET_ARCH in
    aarch64*)
	OPTS="CPU=aarch64"
	;;
    mips64*)
	OPTS="CPU=aarch64"
	;;
    x86_64*)
	OPTS="CPU=x86_64"
	;;
    arm*)
	OPTS="CPU=arm"
	;;
    mips*)
	OPTS="CPU=mips"
	;;
    i*86*)
	OPTS="CPU=i686"
	;;
    esac

    make -C aapt CC=${TARGET_ARCH}-gcc CXX=${TARGET_ARCH}-g++ ${OPTS} EXTRA_CFLAGS="-I${TMPINST_DIR}/include" EXTRA_LDFLAGS="-L${TMPINST_DIR}/lib" || error "build aapt and zipalign"
    make -C aidl CC=${TARGET_ARCH}-gcc CXX=${TARGET_ARCH}-g++ ${OPTS} EXTRA_CFLAGS="-I${TMPINST_DIR}/include" EXTRA_LDFLAGS="-L${TMPINST_DIR}/lib" || error "build aapt and zipalign"

    install -D -m 755 aapt/aapt     ${TMPINST_DIR}/${PKG}/cctools/bin/aapt
    install -D -m 755 aapt/zipalign ${TMPINST_DIR}/${PKG}/cctools/bin/zipalign
    install -D -m 755 aidl/aidl     ${TMPINST_DIR}/${PKG}/cctools/bin/aidl

    install -D -m 755 aproject   ${TMPINST_DIR}/${PKG}/cctools/bin/aproject
    install -D -m 755 jproject   ${TMPINST_DIR}/${PKG}/cctools/bin/jproject

    $STRIP ${TMPINST_DIR}/${PKG}/cctools/bin/*

    cat > ${TMPINST_DIR}/${PKG}/cctools/bin/javac << EOF
#!/system/bin/sh
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH#\$CCTOOLSDIR/lib}
exec dalvikvm \$CCTOOLS_DALVIKVM_ARGS -cp \$CCTOOLSRES com.sun.tools.javac.Main \$@
EOF
    chmod 755 ${TMPINST_DIR}/${PKG}/cctools/bin/javac

    cat > ${TMPINST_DIR}/${PKG}/cctools/bin/dx << EOF
#!/system/bin/sh
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH#\$CCTOOLSDIR/lib}
exec dalvikvm \$CCTOOLS_DALVIKVM_ARGS -cp \$CCTOOLSRES com.android.dx.command.Main \$@
EOF
    chmod 755 ${TMPINST_DIR}/${PKG}/cctools/bin/dx

    cat > ${TMPINST_DIR}/${PKG}/cctools/bin/apkbuilder << EOF
#!/system/bin/sh
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH#\$CCTOOLSDIR/lib}
exec dalvikvm \$CCTOOLS_DALVIKVM_ARGS -cp \$CCTOOLSRES com.android.sdklib.build.ApkBuilderMain \$@
EOF
    chmod 755 ${TMPINST_DIR}/${PKG}/cctools/bin/apkbuilder

    cat > ${TMPINST_DIR}/${PKG}/cctools/bin/apksigner << EOF
#!/system/bin/sh
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH#\$CCTOOLSDIR/lib}
exec dalvikvm \$CCTOOLS_DALVIKVM_ARGS -cp \$CCTOOLSRES com.pdaxrom.cmdline.ApkSigner \$@
EOF
    chmod 755 ${TMPINST_DIR}/${PKG}/cctools/bin/apksigner

    cat > ${TMPINST_DIR}/${PKG}/cctools/bin/proguard << EOF
#!/system/bin/sh
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH#\$CCTOOLSDIR/lib}
exec dalvikvm \$CCTOOLS_DALVIKVM_ARGS -cp \$CCTOOLSRES proguard.ProGuard \$@
EOF
    chmod 755 ${TMPINST_DIR}/${PKG}/cctools/bin/proguard

    cat > ${TMPINST_DIR}/${PKG}/cctools/bin/aproject-helper << EOF
#!/system/bin/sh
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH#\$CCTOOLSDIR/lib}
exec dalvikvm \$CCTOOLS_DALVIKVM_ARGS -cp \$CCTOOLSRES com.pdaxrom.cmdline.AProjectHelper \$@
EOF
    chmod 755 ${TMPINST_DIR}/${PKG}/cctools/bin/aproject-helper

    cat > ${TMPINST_DIR}/${PKG}/cctools/bin/dxrun << EOF
#!/system/bin/sh
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH#\$CCTOOLSDIR/lib}
exec dalvikvm \$CCTOOLS_DALVIKVM_ARGS \$@
EOF
    chmod 755 ${TMPINST_DIR}/${PKG}/cctools/bin/dxrun

    mkdir -p ${TMPINST_DIR}/${PKG}/cctools/share/modules
    cp -f modules/*java.xml ${TMPINST_DIR}/${PKG}/cctools/share/modules/

    local filename="${PKG}_${PKG_VERSION}_${PKG_ARCH}.zip"
    build_package_desc ${TMPINST_DIR}/${PKG} $filename ${PKG} $PKG_VERSION $PKG_ARCH "$PKG_DESC" "fastjar"
    cd ${TMPINST_DIR}/${PKG}
    remove_rpath cctools
    rm -f ${REPO_DIR}/$filename; zip -r9y ${REPO_DIR}/$filename *

    s_tag ${PKG}
}
