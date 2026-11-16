# Biocomposite Stiffness Dataset Generator

Generate training input/output pairs using Python and the existing MATLAB
`computeStiffness` and `hom_biocomp_stiffness` implementation. The MATLAB
stiffness code and its helpers are included unchanged.

This is a self-contained source distribution. A precompiled Linux x86-64
executable and launcher will be included as GitHub Release assets, separately
from the source repository. Place the release files in `runtime_build/` to use
the commands below. The precompiled executable requires MATLAB Runtime R2026a;
MATLAB Compiler is only needed when building locally. Generated datasets and
MATLAB Runtime are not included.

## Requirements

- Python 3.10 or newer, with SciPy, NumPy, and hdf5storage (see `requirements.txt`).
- MATLAB and MATLAB Compiler for the local build. MATLAB dependency analysis
  also identifies Statistics and Machine Learning Toolbox functions in the
  included stiffness source.
- MATLAB or matching MATLAB Runtime to execute the compiled program.

Build on the operating system where the executable will run. MATLAB Runtime
alone cannot compile the source. Runtime must match the MATLAB release used
to compile, at the same update level or newer; see the
[MATLAB Runtime documentation](https://www.mathworks.com/help/compiler/matlab-runtime.html).
The workflow has been tested on Linux with MATLAB R2026a.

## Conda Environment

Install Conda using the [official installation instructions](https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html)
if it is not already available, then open a new terminal. On Linux with Bash,
if your shell has not been initialized for Conda, run `conda init bash` and
restart the terminal before continuing.

Change to the root of this source repository, where `requirements.txt` is
located. Create and activate the environment, then install the Python
dependencies:

```sh
conda create --name biocomp-stiffness --override-channels --channel conda-forge python=3.12 pip
conda activate biocomp-stiffness
python -m pip install -r requirements.txt
```

Check the installation:

```sh
python -c "import sys, scipy, numpy, hdf5storage; from scipy.stats import qmc; print(sys.executable); print('SciPy', scipy.__version__); print('hdf5storage', hdf5storage.__version__)"
python python/generate_dataset.py --help
```

The Python executable should be inside the `biocomp-stiffness` environment.
Keep this environment active for the commands below. In each new terminal,
run `conda activate biocomp-stiffness` again; environment creation and package
installation are only needed once.

This environment is required for the Python generator even when using the
precompiled executable. Install MATLAB Runtime separately; Conda does not
install it. An existing Python environment can also be used by installing
`requirements.txt` with its own `python -m pip`.

## Build and Run

To build locally, run this command from the repository's root. Skip this step
when using the executable from a release:

```sh
matlab -batch "build_runtime_executable"
```

The executable and launcher are written to `runtime_build/`. Keep `fibprops.mat`
and the helper directories in the source checkout; the build bundles them.
The generated `runtime_build/readme.txt` contains platform deployment details.

On Linux, generate a small dataset with:

```sh
python python/generate_dataset.py \
  "runtime_build/run_computeStiffnessCli.sh /usr/local/MATLAB/R2026a" \
  dataset.mat --n-sobol-points 1 --jitter 0
```

Replace `/usr/local/MATLAB/R2026a` with your MATLAB or matching MATLAB Runtime
installation directory. The first argument is the full launcher command and
the second is the output filename.

`--n-sobol-points` defaults to 100000 per orientation distribution, producing
200000 attempted evaluations. `--dataset-index` defaults to 1 and selects
Sobol sequence offsets. `--jitter` defaults to 0.000001.

After the run finishes, leave the Conda environment with:

```sh
conda deactivate
```

## Dataset

The generator samples two orientation distributions using SciPy's
`scipy.stats.qmc.Sobol` with scrambling disabled and optional jitter.
It normalizes microscopic fractions, scales parameters
according to `parameterScaler.m`, and evaluates stiffness.

The output is an HDF5-backed MATLAB v7.3 `.mat` file with:

- `x`: N-by-18 training inputs before parameter scaling, with columns 7 through
  12 normalized to sum to one.
- `y`: N-by-5 outputs ordered as `E_T`, `E_L`, `nu_T`, `nu_LT`, `mu_LT`.

These are the dimensions seen in MATLAB. For nonempty datasets, h5py exposes `x` as
18-by-N and `y` as 5-by-N, matching the surrogate training loader directly.
No format conversion is needed. In Python, use h5py or hdf5storage to read
these files; `scipy.io.loadmat` does not read v7.3 files.

Failed evaluations, NaN outputs, and nonpositive moduli are omitted, so N can
be smaller than the number of attempted samples.
