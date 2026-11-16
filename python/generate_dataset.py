import argparse
import math
import random
import shlex
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

import hdf5storage
import numpy as np
from scipy.io import loadmat, savemat
from scipy.stats import qmc


def sobol_points(n_points, dim, skip):
    sampler = qmc.Sobol(d=dim, scramble=False)

    if skip > 0:
        sampler.fast_forward(skip)

    return sampler.random(n_points).tolist()


def parameter_scaler(x):
    x = list(x)

    x2Min = math.log10(1.2)
    x2Max = math.log10(20000)

    x3Min = -10
    x3Max = math.log10(100)

    x4Min = 0
    x4Max = 45

    x5Min = 10 ** (-10)
    x5Max = 0.99

    x6Min = 10 ** (-10)
    x6Max = 1

    x7Min = 0.05
    x7Max = 0.9

    x8Min = 0.01
    x8Max = 0.5

    x9Min = 0.01
    x9Max = 0.6

    x10Min = 0
    x10Max = 0.15

    x11Min = 0
    x11Max = 0.15

    x12Min = 0
    x12Max = 0.2

    x13Min = 0.2
    x13Max = 1

    x14Min = 0
    x14Max = 100

    x15Min = 0
    x15Max = 0.5

    x16Min = 0
    x16Max = 0.5

    x17Min = -10
    x17Max = math.log10(100000)

    x18Min = -10
    x18Max = math.log10(100000)

    x[1] = scale_x(x, 1, x2Min, x2Max)
    x[2] = scale_x(x, 2, x3Min, x3Max)
    x[3] = scale_x(x, 3, x4Min, x4Max)
    x[4] = scale_x(x, 4, x5Min, x5Max)
    x[5] = scale_x(x, 5, x6Min, x6Max)
    x[6] = scale_x(x, 6, x7Min, x7Max)
    x[7] = scale_x(x, 7, x8Min, x8Max)
    x[8] = scale_x(x, 8, x9Min, x9Max)
    x[9] = scale_x(x, 9, x10Min, x10Max)
    x[10] = scale_x(x, 10, x11Min, x11Max)
    x[11] = scale_x(x, 11, x12Min, x12Max)
    x[12] = scale_x(x, 12, x13Min, x13Max)
    x[13] = scale_x(x, 13, x14Min, x14Max)
    x[14] = scale_x(x, 14, x15Min, x15Max)
    x[15] = scale_x(x, 15, x16Min, x16Max)
    x[16] = scale_x(x, 16, x17Min, x17Max)
    x[17] = scale_x(x, 17, x18Min, x18Max)

    x[1] = 10 ** x[1]
    x[2] = 10 ** x[2]

    x[16] = 10 ** x[16]
    x[17] = 10 ** x[17]

    return x


def scale_x(x, index, x_min, x_max):
    x_interval = x_max - x_min
    return x_interval * x[index] + x_min


def normalize_microscopic(x):
    x = list(x)
    x_sum = sum(x[6:12])

    for ii in range(6, 12):
        x[ii] = x[ii] / x_sum

    return x


def runtime_stiffness(runtime_command, x):
    with TemporaryDirectory() as directory:
        input_file = Path(directory) / "inputs.mat"
        output_file = Path(directory) / "outputs.mat"
        savemat(input_file, {"x": x}, format="4")
        cmd = shlex.split(runtime_command) + [str(input_file), str(output_file)]
        subprocess.run(cmd, check=True)
        return loadmat(output_file)["y"].tolist()


def save_mat(file_name, x, y):
    x = np.asarray(x, dtype=np.float64).reshape(-1, 18)
    y = np.asarray(y, dtype=np.float64).reshape(-1, 5)
    hdf5storage.savemat(str(file_name), {"x": x, "y": y}, fmt="7.3",
                       appendmat=False, store_python_metadata=False,
                       truncate_existing=True)


def generate_dataset(runtime_command, file_name, n_sobol_points, dataset_index, jitter):
    upper_skip = (10 + dataset_index) * n_sobol_points
    lower_skip = (11 + dataset_index) * n_sobol_points

    x_upper = sobol_points(n_sobol_points, 17, upper_skip)
    x_lower = sobol_points(n_sobol_points, 17, lower_skip)

    x_upper = [[xx + jitter * (random.random() - 0.5) for xx in row] for row in x_upper]
    x_lower = [[xx + jitter * (random.random() - 0.5) for xx in row] for row in x_lower]

    inputs = [[0] + row for row in x_upper] + [[1] + row for row in x_lower]
    inputs = [normalize_microscopic(row) for row in inputs]
    scaled_inputs = [parameter_scaler(row) for row in inputs]
    outputs = runtime_stiffness(runtime_command, scaled_inputs)

    x = []
    y = []

    for ii in range(len(inputs)):
        train_ii = inputs[ii]
        y_ii = outputs[ii]

        if len(y_ii) != 5:
            continue

        if any(math.isnan(yy) for yy in y_ii):
            continue

        moduli_ii = [y_ii[0], y_ii[1], y_ii[4]]
        negative_moduli = any(mm <= 0 for mm in moduli_ii)

        if negative_moduli:
            continue

        x.append(train_ii)
        y.append(y_ii)

    save_mat(file_name, x, y)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("runtime_command")
    parser.add_argument("file_name")
    parser.add_argument("--n-sobol-points", type=int, default=100000)
    parser.add_argument("--dataset-index", type=int, default=1)
    parser.add_argument("--jitter", type=float, default=0.000001)
    args = parser.parse_args()

    generate_dataset(args.runtime_command, args.file_name, args.n_sobol_points, args.dataset_index, args.jitter)


if __name__ == "__main__":
    main()
