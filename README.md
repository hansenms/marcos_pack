# MaRCoS Pack with DevContainer

This repo is a fork of the [MaRCoS Pack](https://github.com/vnegnev/) repository to facilitate working with the MaRCoS code
and getting up and running running with the tutorials on the [wiki](https://github.com/vnegnev/marcos_extras/wiki).

After starting the devcontainer, first:

```bash
cd /workspaces/marcos_pack/marga
rm -rf build
mkdir -p build
cd build
cmake ../src/
```

And then run the tests:

```bash
cd /workspaces/marcos_pack/marcos_client
python3 test_marga_model.py
```

This will effectively take you to the end of the [MaRCoS setup tutorial](https://github.com/vnegnev/marcos_extras/wiki/tut_set_up_marcos_software) and you can start running experiments. Open the [experiments.ipynb](experiments.ipynb) notebook to run the first experiment.