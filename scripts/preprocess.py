import os
import re
import subprocess


GREEN = f'\033{chr(91)}92m'
BLUE = f'\033{chr(91)}94m'
RESET = f'\033{chr(91)}0m'


def main() -> None:
    ss = []

    while True:
        try:
            s = input()

        except EOFError:
            break

        ss.append(s)

    entries = []

    for s in ss[1:]:
        permission, _, size, month, day, time, *_ = s.split()
        path = re.match(rf'{permission}\s+\d+\s+{size}\s+{month}\s+{day}\s+{time}\s+(.+)', s)

        if path is None:
            continue

        path = path.group(1).strip()

        if os.path.isdir(path):
            entries.append((path, permission, size, month, day, time))

    length = [max(len(str(entry[i])) for entry in entries) for i in range(6)]

    p = subprocess.Popen(['tmux', 'display-message', '-p', '#{window_width}'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = p.communicate()

    if len(out) == 0 or len(err) != 0:
        out = f'{os.get_terminal_size().columns}'

    if len(out) == 0:
        print('ERROR: cannot get window size')

        exit(1)

    max_length = int(int(int(out.strip()) * 0.8) * 0.4) - 5
    color = [BLUE, '', GREEN, BLUE, BLUE, BLUE]

    for entry in entries:
        directory = entry[0]

        base_length = (sum(length[1:]) + 4)
        text_length = len(entry[0]) + base_length

        for i in range(len(entry[0]) + 1):
            directory = entry[0][: (len(entry[0]) - i)]

            origin_length = len(directory)
            encode_length = len(directory.encode())
            delta = ((encode_length - origin_length) if origin_length != encode_length else 0) // 2

            text_length = origin_length + base_length + delta

            if text_length + 5 < max_length:
                break

        if len(directory) == 0:
            print('ERROR: window width not enough')

            exit(1)

        strip = directory != entry[0]
        padding = ' ' * (max_length - text_length - (3 if strip else 0))

        prefix = f'{color[0]}{directory}{"..." if strip else ""}{RESET}'
        postfix = ' '.join([f'{_color}{_entry:>{_length}}{RESET}' for _color, _entry, _length in zip(color[1:], entry[1:], length[1:])])

        s = prefix + padding + postfix
        print(s)


if __name__ == '__main__':
    main()
