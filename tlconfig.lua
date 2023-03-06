return {
	global_env_def = 'src/eso',
	source_dir = 'src',
	build_dir = 'build',
	dont_prune = {
		"**/*.txt"
	},
	scripts = {
		build = {
			pre = 'clean.tl',
			post = 'copyFiles.tl'
		}
	}
}
