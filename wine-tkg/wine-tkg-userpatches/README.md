# Wine-tkg userpatches

You can make use of your own patches by putting them in this folder before running makepkg.

They need to be diffs against the targeted tree.

To specify the targeted tree, give your patch the appropriate extension:

**!! Patches with unrecognized extension will get ignored !!**

## For wine itself (apply after all other patches)
- `.mypatch` — apply a wine patch
- `.myrevert` — revert a wine patch
- `.mylatepatch` — apply late (after make_vulkan/make_requests/autoreconf)
- `.mylaterevert` — revert late

## For wine-staging patchsets (apply to staging tree BEFORE it's applied to wine)
- `.mystagingpatch` — apply a staging patchset patch
- `.mystagingrevert` — revert a staging patchset patch
