import os
import re


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

    max_length = 75
    color = [BLUE, '', GREEN, BLUE, BLUE, BLUE]

    for entry in entries:
        directory = entry[0]

        while True:
            _origin_length = len(directory)
            _encode_length = len(directory.encode())
            delta = ((_encode_length - _origin_length) if _origin_length != _encode_length else 0) // 2

            text_length = _origin_length + (sum(length[1:]) + 4) + delta

            if text_length + 5 < max_length:
                break

            directory = directory[:-1]

        strip = directory != entry[0]
        padding = ' ' * (max_length - text_length - (3 if strip else 0))

        prefix = f'{color[0]}{directory}{"..." if strip else ""}{RESET}'
        postfix = ' '.join([f'{_color}{_entry:>{_length}}{RESET}' for _color, _entry, _length in zip(color[1:], entry[1:], length[1:])])

        s = prefix + padding + postfix
        print(s)


if __name__ == '__main__':
    main()
