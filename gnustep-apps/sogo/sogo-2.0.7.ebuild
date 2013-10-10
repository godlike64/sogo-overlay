# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit gnustep-base flag-o-matic


DESCRIPTION="Groupware server built around OpenGroupware.org and the SOPE application server"
HOMEPAGE="http://sogo.opengroupware.org/"
SRC_URI="http://www.sogo.nu/files/downloads/SOGo/Sources/SOGo-${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="postgres mysql logrotate"
DEPEND="gnustep-libs/sope[ldap,mysql?,postgres?]
	!mysql? ( !postgres? ( dev-db/postgresql-base ) )
	dev-libs/libmemcached
	net-misc/memcached
	net-nds/openldap"
RDEPEND="${DEPEND}
	logrotate? ( app-admin/logrotate )"

S=${WORKDIR}/${PN}

pkg_setup() {
	gnustep-base_pkg_setup
	local myLDFLAGS="$(gnustep-config --variable=LDFLAGS 2>/dev/null)"
	if [ -n "${myLDFLAGS}" ] && (echo "${myLDFLAGS}" | grep -q "\-\-a\(dd\|s\)\-needed" 2>/dev/null); then
		ewarn
		ewarn "You seem to have compiled GNUstep with custom LDFLAGS:"
		for foo in $(gnustep-config --variable=LDFLAGS); do
			ewarn "  "${foo}
		done
		ewarn
		ewarn "SOGo is very sensitive regarding custom LDFLAGS. Especially with:"
		ewarn "  --add-needed"
		ewarn "  --as-needed"
		ewarn
		ewarn "If your SOGo install does not work as expected then please re-emerge SOGo,"
		ewarn "SOPE and your GNUstep (base and make) without any LDFLAGS before filing bugs."
		ewarn
	fi
	append-ldflags -Wl,--no-as-needed
}

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"
	mv "SOGo-${PV}" "${PN}"
}

src_configure() {
	cd "${S}"
	egnustep_env
	./configure \
		$(use_enable debug) \
		--disable-strip || die "configure failed"
}

src_install() {
	gnustep-base_src_install
	newinitd "${FILESDIR}"/sogod.initd sogod \
		|| die "Init script installation failed"
	newconfd "${FILESDIR}"/sogod.confd sogod \
		|| die "Conf.d installation failed"
	if use logrotate; then
		insopts -m644 -o root -g root
		insinto /etc/logrotate.d
		newins Scripts/logrotate SOGo || die "Failed to install logrotate.d file"
	fi
	newdoc Apache/SOGo.conf SOGo-Apache.conf
}

pkg_preinst() {
	enewgroup sogo
	enewuser sogo -1 /bin/bash /var/lib/sogo sogo
}

pkg_postinst() {
	gnustep-base_pkg_postinst
	elog
	elog "Now follow the steps from the SOGo documentation:"
	elog "http://www.sogo.nu/files/docs/SOGo%20Installation%20Guide.pdf"
	elog "The sogo user home directory is /var/lib/sogo"
	elog
	elog "Then you can start/stop sogo with /etc/init.d/sogod"
	elog
	elog "If you plan to use SOGo with Apache then please have a look at the"
	elog "'SOGo-Apache.conf' included in the documentation directory of this"
	elog "SOGo installation and don't forget to add '-D PROXY' to your"
	elog "APACHE2_OPTS."
	elog
	elog "If you plan to use SOGo with Nginx have a look at SOGo's wiki:"
	elog "http://wiki.sogo.nu/nginxSettings"
	elog
}
