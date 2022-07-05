import yaml
import numpy as np
import sys

TOL = 1e-14

def clean_unidentified_modes(unidentified):
    unidentified_modes = np.array([
        [val for node in mode.values() for val in node] 
             for mode in unidentified.values()
    ])
    unidentified_modes[abs(unidentified_modes) < TOL] = 0.0
    return unidentified_modes


def label_unidentified(baseline, unidentified_dict, compare = None, verbose=True):
    identified_keys = set()
    identified = {}
    _old_labels = list(unidentified_dict.keys())

    if compare is None:
        _compare = lambda errors, labels: np.argmin(errors)
    elif compare == "max":
        _compare = lambda errors, labels: np.argmax(errors[~np.isin(np.arange(len(errors)), labels)])

    unidentified = clean_unidentified_modes(unidentified_dict)

    for key, mode in baseline.items():
        baseline_data = np.array([*mode.values()]).flatten()
        baseline_data[abs(baseline_data) < TOL] = 0.0
        scale_index = np.argmax(np.absolute(baseline_data))
        baseline_scale = baseline_data[scale_index]

        errors = np.sum(abs(baseline_data - unidentified*baseline_scale/unidentified[:,scale_index][:,None]), axis=1)
        index = _compare(errors, identified_keys)
        old_label = _old_labels[index]
        if verbose:
            print(f"{old_label} -> {key}", file=sys.stderr)

        if  old_label in identified_keys and verbose:
            print(f"WARNING: duplicate identification of key {old_label}")

        identified_keys.add(_old_labels[index])
        identified[key] = unidentified[index]

    return identified


if __name__ == "__main__":
    index = 1
    compare = None
    if len(sys.argv) > 3:
        compare = sys.argv[1][2:]
        index += 1

    baseline_file, unidentified_file = sys.argv[index:]
    with open(unidentified_file, "r") as f:
        unidentified = yaml.load(f, Loader=yaml.Loader)

    with open(baseline_file, "r") as f:
        baseline = yaml.load(f, Loader=yaml.Loader)

    for nodes in unidentified.values():
        node_names = list(nodes.keys())
        break

    # print(yaml.dump(
    #     {
    #         key: {
    #             node_name: [float(v) for v in node_vals] 
    #               for node_name, node_vals in 
    #                  zip(node_names, mode.reshape((-1, len(node_names))).T)
    #         } for key, mode in 

    #         label_unidentified(baseline, unidentified, compare=compare).items()
    #     }
    # ))

    for k,mode in label_unidentified(baseline, unidentified, compare=compare).items():
        print(f"{k}:\n\t")
        print("\n\t".join((f"{node_name}: [{','.join(str(v) for v in node_vals)}]"
                  for node_name, node_vals in 
                     zip(node_names, mode.reshape((-1, len(node_names))).T)
        )))
