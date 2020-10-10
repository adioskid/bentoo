ALL_ARM_ARCHS=(
	armv4t
	armv5t armv5te
	armv6 armv6j armv6kz armv6t2 armv6z armv6zk
	armv6-m armv6s-m
	armv7 armv7-a armv7ve
	armv7-r
	armv7-m armv7e-m
	armv8-a armv8.1-a armv8.2-a armv8.3-a armv8.4-a
	armv8-r
	armv8-m.base armv8-m.main
	iwmmxt iwmmxt2
)

ARM_V5_V6_FPUS=(
	vfpv2 vfp # vfp -> vfpv2
)
ARM_V7_FPUS=(
	vfpv3-d16
)
ARM_V7_A_FPUS=(
	vfpv3-d16 # +fp
	neon-vfpv3 neon neon-fp16 # +simd; neon -> neon-vfpv3
	vfpv3 vfpv3-d16-f16 vfpv3-fp16
	vfpv4-d16 vfpv4
	neon-vfpv4
)

ARM_V7VE_FPUS=(
	vfpv4-d16 # +fp
	neon-vfpv4 # +simd
	vfpv3-d16 vfpv3 vfpv3-d16-f16 vfpv3-fp16
	vfpv4
	neon-vfpv3 neon neon-fp16 # neon -> neon-vfpv3
)

ALL_ARM_FPUS=(
	vfpv2 vfp # vfp -> vfpv2
	vfpv3 vfpv3-fp16 vfpv3-d16 vfpv3-d16-fp16 vfpv3xd vfpv3xd-fp16
	neon-vfpv3 neon neon-fp16 # neon -> neon-vfpv3
	vfpv4 vfpv4-d16 fpv4-sp-d16
	neon-vpfv4
	fpv5-d16 fpv5-sp-d16
	fp-armv8 neon-fp-armv8 crypto-neon-fp-armv8
)

for fpu in ALL_ARM_FPUS[@] ; do
	IUSE_ARM_FPUS="${IUSE_ARM_FPUS} fpu_${fpu}"
done

IUSE="${IUSE} ${IUSE_ARM_FPUS}"



gcc_arch_arm_setup() {

	# ARM
	if [[ ${CTARGET} == arm* ]] ; then

		arm_arch=
		gcc_arm_arch=""
		gcc_arm_floatabi=""
		gcc_arm_fpu=""

		local a arm_arch=${CTARGET%%-*}
		# Remove trailing endian variations first: eb el be bl b l
		for a in e{b,l} {b,l}e b l ; do
			if [[ ${arm_arch} == *${a} ]] ; then
				arm_arch=${arm_arch%${a}}
				break
			fi
		done

		# Convert armv7{a,r,m} to armv7-{a,r,m}
		local arm_arch_without_dash=${arm_arch}
		[[ ${arm_arch} == armv[6-8]*[^-][arm] ]] && arm_arch=${arm_arch%?}-${arm_arch##${arm_arch%?}}
		# See if this is a valid --with-arch flag
		if (srcdir=${S}/gcc target=${CTARGET} with_arch=${arm_arch};
			. "${srcdir}"/config.gcc) &>/dev/null
		then
			gcc_arm_arch="${arm_arch}"
		fi

		# Enable hardvfp
		local CTARGET_TMP=${CTARGET:-${CHOST}}
		if [[ ${CTARGET_TMP//_/-} == *-softfloat-* ]] ; then
			conf_gcc_arm_floatabi="soft"
		elif [[ ${CTARGET_TMP//_/-} == *-softfp-* ]] ; then
			conf_gcc_arm_floatabi="softfp"
		else
			if [[ ${CTARGET} == armv[6-8]* ]]; then
				case ${CTARGET} in
					armv5t|armv5te|armv6|armv6[jkz]|armv6kz|armv6t2|armv6zk) gcc_arm_fpu="vfpv2" ;;
					armv7|arm7a) gcc_arm_fpu="vfpv3-d16" ;;
					armv7ve) gcc_arm_fpu="vfpv4-d16" ;;
				esac

				realfpu=$( echo "${CFLAGS}" | sed 's/.*mfpu=\([^ ]*\).*/\1/')
				if [ "${realfpu}" = "${CFLAGS}" ] ;then
					realfpu=""
					case ${CTARGET} in
						armv5*|armv6*) for fpu in ${ARM_V5_V6_FPUS[@]} ; do use fpu_${fpu} && realfpu=${fpu} ; done ;;
						armv7) for fpu in ${ARM_V7_FPUS[@]} ; do use fpu_${fpu} && realfpu=${fpu} ; done ;;
						armv7a) for fpu in ${ARM_V7_A_FPUS[@]} ; do use fpu_${fpu} && realfpu=${fpu} ; done ;;
						armv7ve) for fpu in ${ARM_V7VE_FPUS[@]} ; do use fpu_${fpu} && realfpu=${fpu} ; done ;;
					esac
				fi
				if [ -z "${realfpu}" ] ; then
					conf_gcc_arm+=" --with-fpu=${gcc_arm_fpu}"
				else
					conf_gcc_arm+=" --with-fpu=${realfpu}"
				fi
			fi
			conf_gcc_arm_floatabi="hard"
		fi
		conf_gcc_arm+=" --with-float=${conf_gcc_arm_floatabi}"
	fi

gcc_conf_arm_opts() {
	printf -- "${conf_gcc_arm}"
}

gcc_conf_arm_post() {
	if use arm ; then
		# Source : https://sourceware.org/bugzilla/attachment.cgi?id=6807
		# Workaround for a problem introduced with GMP 5.1.0.
		# If configured by gcc with the "none" host & target, it will result in undefined references
		# to '__gmpn_invert_limb' during linking.
		# Should be fixed by next version of gcc.
		sed -i "s/none-/${arm_arch_without_dash}-/" ${WORKDIR}/objdir/Makefile || die
	fi

}

