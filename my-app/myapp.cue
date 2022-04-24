package myapp

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/alpine"
	"universe.dagger.io/bash"
	"universe.dagger.io/docker"
)

dagger.#Plan & {
	_nodeModulesMount: "/src/node_modules": {
		dest:     "/src/node_modules"
		type:     "cache"
		contents: core.#CacheDir & {
			id: "myapp-modules-cache"
		}

	}
	client: {
		filesystem: {
			"./": read: {
				contents: dagger.#FS
				exclude: [
					"README.md",
					"_build",
					"myapp.cue",
					"node_modules",
				]
			}
			"./_build": write: contents: actions.build.contents.output
		}
		env: {
			APP_NAME:      string
		}
	}
	actions: {
		deps: docker.#Build & {
			steps: [
				alpine.#Build & {
					packages: {
						bash: {}
						yarn: {}
						git: {}
					}
				},
				docker.#Copy & {
					contents: client.filesystem."./".read.contents
					dest:     "/src"
				},
				bash.#Run & {
					workdir: "/src"
					mounts: {
						"/cache/yarn": {
							dest:     "/cache/yarn"
							type:     "cache"
							contents: core.#CacheDir & {
								id: "myapp-yarn-cache"
							}
						}
						_nodeModulesMount
					}
					script: contents: #"""
						yarn config set cache-folder /cache/yarn
						yarn install
						"""#
				},
			]
		}

		test: bash.#Run & {
			input:   deps.output
			workdir: "/src"
			mounts:  _nodeModulesMount
			script: contents: #"""
				yarn run test
				"""#
		}

		build: {
			run: bash.#Run & {
				input:   test.output
				mounts:  _nodeModulesMount
				workdir: "/src"
				script: contents: #"""
					yarn run build
					"""#
			}

			contents: core.#Subdir & {
				input: run.output.rootfs
				path:  "/src/build"
			}
		}

		deploy: {
			contents: build.contents.output
		}
	}
}
