# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit gnustep-base apache-module

MY_PV="1660-200908051100"

DESCRIPTION="An extensive set of frameworks which form a complete Web application server environment"
HOMEPAGE="http://sope.opengroupware.org/en/index.html"
SRC_URI="http://www.sogo.nu/files/downloads/SOGo/Sources/SOPE-${PV}.tar.gz"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug ldap mysql postgres sqlite"
DEPEND="gnustep-base/gnustep-base
	dev-libs/libxml2
	dev-libs/openssl
	ldap? ( net-nds/openldap )
	mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql-base )
	sqlite? ( >=dev-db/sqlite-3.0 )"
RDEPEND="${DEPEND}"


S=${WORKDIR}/${PN}

want_apache

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
		ewarn "SOPE is very sensitive regarding custom LDFLAGS. Especially with:"
		ewarn "  --add-needed"
		ewarn "  --as-needed"
		ewarn
		ewarn "If your SOPE install does not work as expected then please re-emerge SOPE"
		ewarn "and your GNUstep (base and make) without any LDFLAGS before filing bugs."
		ewarn
	fi
	append-ldflags -Wl,--no-as-needed
}

src_prepare() {
	gnustep-base_src_prepare
}

src_configure() {
	cd "${S}"
	./configure \
		$(use_enable debug) \
		$(use_enable debug strip) \
		--with-gnustep ${myconf} || die "configure failed"
}

src_compile() {
	egnustep_env
	local myconf
	egnustep_make ${myconf}
}


src_install() {
	gnustep-base_src_install
}

pkg_postinst() {
	gnustep-base_pkg_postinst
}
