# MaRCoS Pack with DevContainer

This repo is a fork of the [MaRCoS Pack](https://github.com/vnegnev/) repository to facilitate working with the MaRCoS code
and getting up and running running with the tutorials on the [wiki](https://github.com/vnegnev/marcos_extras/wiki).

This enhanced version adds real-time data streaming capabilities to the MaRCoS system, allowing for real-time visualization and analysis of data during experiment execution. See [streaming_impl_README.md](streaming_impl_README.md) for details.

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

## Real-Time Data Streaming

To try out the real-time data streaming functionality:

1. Start the MaRCoS server with streaming support:
```bash
cd /workspaces/marcos_pack/marcos_server/build
./marcos_server
```

2. In a separate terminal, run the streaming test:
```bash
cd /workspaces/marcos_pack
python3 test_streaming.py
```

3. For a more interactive experience, open the [streaming_demo.ipynb](streaming_demo.ipynb) notebook which demonstrates real-time visualization of streaming data.