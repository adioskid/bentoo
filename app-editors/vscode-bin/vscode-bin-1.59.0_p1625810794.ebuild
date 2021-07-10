# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils pax-utils xdg

MY_INSTALL_DIR="/opt/${PN}"
MY_EXEC="code-insiders"
MY_PN=${PN/-bin/}

DESCRIPTION="Multiplatform Visual Studio Code from Microsoft"
HOMEPAGE="https://code.visualstudio.com"
SRC_URI="https://az764295.vo.msecnd.net/insider/87d692b7bf1eb5a663b3e62620a6e7e436e1838c/code-insider-x64-1625811121.tar.gz -> vscode-bin-1.59.0_p1625810794.tar.gz"
RESTRICT="mirror strip"
LICENSE="Microsoft"
SLOT="0"
KEYWORDS=""
IUSE="libsecret hunspell"
DEPEND="
	media-libs/libpng
	>=x11-libs/gtk+-3.0
	x11-libs/cairo
	x11-libs/libXtst
"
RDEPEND="
	${DEPEND}
        >=net-print/cups-2.0.0
        x11-libs/libnotify
        x11-libs/libXScrnSaver
        dev-libs/nss
        hunspell? ( app-text/hunspell )
        libsecret? ( app-crypt/libsecret[crypt] )
"

pkg_setup() {
	S="${WORKDIR}/VSCode-linux-x64"
}

src_install() {
	pax-mark m "${MY_INSTALL_DIR}/${MY_EXEC}"
	insinto "${MY_INSTALL_DIR}"
	doins -r *
	dosym "${MY_INSTALL_DIR}/${MY_EXEC}" "/usr/bin/${PN}"
	make_wrapper "${PN}" "${MY_INSTALL_DIR}/${MY_EXEC}"
	domenu ${FILESDIR}/${PN}.desktop
	newicon ${S}/resources/app/resources/linux/code.png ${PN}.png

	fperms +x "${MY_INSTALL_DIR}/${MY_EXEC}"
	fperms 4755 "${MY_INSTALL_DIR}/chrome-sandbox"
	fperms +x "${MY_INSTALL_DIR}/libEGL.so"
	fperms +x "${MY_INSTALL_DIR}/libGLESv2.so"
	fperms +x "${MY_INSTALL_DIR}/libffmpeg.so"
	fperms +x "${MY_INSTALL_DIR}/libvk_swiftshader.so"
	fperms +x "${MY_INSTALL_DIR}/resources/app/extensions/git/dist/askpass-empty.sh"
	fperms +x "${MY_INSTALL_DIR}/resources/app/extensions/git/dist/askpass.sh"
	fperms +x "${MY_INSTALL_DIR}/resources/app/extensions/ms-vscode.js-debug/src/terminateProcess.sh"
	fperms +x "${MY_INSTALL_DIR}/resources/app/extensions/ms-vscode.node-debug/dist/terminateProcess.sh"
	fperms +x "${MY_INSTALL_DIR}/resources/app/extensions/ms-vscode.node-debug2/out/src/terminateProcess.sh"
	fperms +x "${MY_INSTALL_DIR}/resources/app/extensions/ms-vscode.node-debug2/src/terminateProcess.sh"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/keytar/build/Release/keytar.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/keytar/build/Release/obj.target/keytar.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/native-is-elevated/build/Release/iselevated.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/native-keymap/build/Release/keymapping.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/native-watchdog/build/Release/watchdog.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/node-pty/build/Release/pty.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/nsfw/build/Release/nsfw.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/spdlog/build/Release/spdlog.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/vscode-encrypt/build/Release/vscode-encrypt-native.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/rg"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/vscode-sqlite3/build/Release/sqlite.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/vsda/build/Release/vsda.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/windows-foreground-love/build/Release/foreground_love.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/node_modules.asar.unpacked/windows-foreground-love/build/Release/obj.target/foreground_love.node"
	fperms +x "${MY_INSTALL_DIR}/resources/app/out/vs/base/node/cpuUsage.sh"
	fperms +x "${MY_INSTALL_DIR}/resources/app/out/vs/base/node/ps.sh"
	fperms +x "${MY_INSTALL_DIR}/resources/app/out/vs/base/node/terminateProcess.sh"
	fperms +x "${MY_INSTALL_DIR}/swiftshader/libEGL.so"
	fperms +x "${MY_INSTALL_DIR}/swiftshader/libGLESv2.so"
	insinto "/usr/share/licenses/${PN}"
	newins "resources/app/LICENSE.rtf" "LICENSE.rtf"
}

pkg_postinst() {
	xdg_desktop_database_update
	elog "You may install some additional utils, so check them in:"
	elog "https://code.visualstudio.com/Docs/setup#_additional-tools"
}

pkg_postrm() {
	xdg_desktop_database_update
}