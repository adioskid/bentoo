#!/bin/sh

gcc_svn_diff_branch_since_release() {
	local my_branch="${1}" ; shift
	local my_release_tag="${1}" ; shift
	local my_out_dir="$(realpath -e ${1})" ; shift
	local my_release="$(printf -- "${my_release_tag}" | sed -re 's/gcc_([0-9]+)_([0-9]+)_([0-9]+)_release/\1.\2.\3/')"

	echo "${my_release_tag} -> ${my_branch} (tip):"
	local my_release_rev="$(svn ls -v "${GCC_SVN_REPO}/tags" | grep "${my_release_tag}" | sed -rn 's/[[:space:]]*([[:digit:]]+).*/\1/p')"
	local my_branch_rev="$(svn ls -v "${GCC_SVN_REPO}/branches" | grep "${my_branch}" | sed -rn 's/[[:space:]]*([[:digit:]]+).*/\1/p')"

	echo "RELEASE REVISION=${my_release_rev}"
	[ -z "${my_release_rev}" ] && return 1
	echo "BRANCH TIP REVISION=${my_branch_rev}"
	[ -z "${my_branch_rev}" ] && return 1

	if [ ${my_branch_rev} -lt ${my_release_rev} ] ; then
		echo "Release revision is newer than branch tip. Skipping"
		return 1
	elif [ ${my_branch_rev} -eq ${my_release_rev} ] ; then
		echo "Release revision is up to date with branch tip. Skipping"
		return 1
	fi
	
	printf -- "Generating '${my_out_dir}/gcc-${my_release}-to-svn-${my_branch_rev}.patch'..."

	svn diff --git --old "${GCC_SVN_REPO}/tags/${my_release_tag}" --new "${GCC_SVN_REPO}/branches/${my_branch}" \
		| sed -re 's: (a|b)/(branches|tags)/: \1/:g' \
		> "${my_out_dir}/gcc-${my_release}-to-svn-${my_branch_rev}.patch"

	printf -- " Done.\n"
}

[ $# -ne 1 ] && printf -- "Please supply patch output dir" && false

diff_out_dir="${1}";shift

mkdir -p "${diff_out_dir}"

GCC_SVN_REPO="http://gcc.gnu.org/svn/gcc"
gcc_svn_diff_branch_since_release gcc-5-branch gcc_5_5_0_release "${diff_out_dir}"
gcc_svn_diff_branch_since_release gcc-6-branch gcc_6_5_0_release "${diff_out_dir}"
gcc_svn_diff_branch_since_release gcc-7-branch gcc_7_4_0_release "${diff_out_dir}"
gcc_svn_diff_branch_since_release gcc-8-branch gcc_8_3_0_release "${diff_out_dir}"
gcc_svn_diff_branch_since_release gcc-9-branch gcc_9_1_0_release "${diff_out_dir}"

