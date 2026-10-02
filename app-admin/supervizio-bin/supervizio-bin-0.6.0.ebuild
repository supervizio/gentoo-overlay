# Copyright 2026 superviz.io
# Distributed under the terms of the MIT License

# supervizio v0.6.0, written by supervizio/agent's release pipeline
# (setup/packaging/render-channels.py) and replaced by the next release.
# The distfile is the release's statically linked binary; the Manifest binds
# it by BLAKE2B and SHA512.

EAPI=8

inherit systemd

DESCRIPTION="PID1-capable process supervisor and OpenTelemetry collector agent"
HOMEPAGE="https://supervizio.github.io/agent/"
SRC_URI="
	amd64? ( https://supervizio.github.io/agent/dist/v0.6.0/supervizio-linux-amd64-musl -> supervizio-bin-0.6.0-amd64 )
	arm64? ( https://supervizio.github.io/agent/dist/v0.6.0/supervizio-linux-arm64-musl -> supervizio-bin-0.6.0-arm64 )
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64"
# mirror: served by supervizio's own site, not by Gentoo's mirrors.
# strip: installed as published -- the bytes the release's E2E ran.
RESTRICT="mirror strip"

QA_PREBUILT="usr/bin/supervizio"

src_unpack() {
	# The distfile is the executable itself: there is nothing to unpack.
	:
}

src_install() {
	newbin "${DISTDIR}/${P}-${ARCH}" supervizio

	# The OpenRC script and the systemd unit every other supervizio package
	# installs, pointed at the binary's place here: a package manager
	# installs into /usr/bin, never into /usr/local.
	local f
	for f in supervizio.initd supervizio.service; do
		sed -e 's|/usr/local/bin/supervizio|/usr/bin/supervizio|g' \
			"${FILESDIR}/${f}" > "${T}/${f}" || die
	done
	newinitd "${T}/supervizio.initd" supervizio
	systemd_dounit "${T}/supervizio.service"

	insinto /etc/supervizio
	doins "${FILESDIR}/config.example.yaml"
	keepdir /var/log/supervizio
}

pkg_postinst() {
	# Like every other supervizio package: a first install copies the example
	# configuration into place, and the copy is the administrator's from then
	# on -- no upgrade or removal touches it.
	if [[ ! -e ${EROOT}/etc/supervizio/config.yaml ]]; then
		cp "${EROOT}/etc/supervizio/config.example.yaml" \
			"${EROOT}/etc/supervizio/config.yaml" || die
		elog "Wrote /etc/supervizio/config.yaml from config.example.yaml."
	fi
	elog "To start supervizio now and at boot:"
	elog "  OpenRC:  rc-update add supervizio default && rc-service supervizio start"
	elog "  systemd: systemctl enable --now supervizio"
}
