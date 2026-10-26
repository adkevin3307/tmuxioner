import math
import os
import shutil
import stat
import subprocess
import sys
import time
import unicodedata


GREEN = f'\033{chr(91)}92m'
BLUE = f'\033{chr(91)}94m'
RESET = f'\033{chr(91)}0m'

SIX_MONTHS = 182.5 * 24 * 60 * 60


def display_width(s: str) -> int:
    return sum(0 if unicodedata.combining(c) else 2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in s)


def human_size(size: int) -> str:
    # same format as `ls -h`
    if size < 1024:
        return str(size)

    value = float(size)

    for unit in ['K', 'M', 'G', 'T', 'P']:
        value /= 1024

        # round up like `ls`, carry to the next unit when it reaches 1024
        if math.ceil(value) < 1024 or unit == 'P':
            break

    if math.ceil(value * 10) < 100:
        return f'{math.ceil(value * 10) / 10:.1f}{unit}'

    return f'{math.ceil(value)}{unit}'


def modify_time(mtime: float) -> tuple[str, str, str]:
    # same format as `ls -l`, year instead of time for files older than six months
    t = time.localtime(mtime)
    recent = abs(time.time() - mtime) < SIX_MONTHS

    return time.strftime('%b', t), str(t.tm_mday), time.strftime('%H:%M', t) if recent else str(t.tm_year)


def window_width() -> int:
    p = subprocess.Popen(['tmux', 'display-message', '-p', '#{window_width}'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = p.communicate()

    if len(out.strip()) == 0 or len(err) != 0:
        return shutil.get_terminal_size().columns

    return int(out.strip())


def directories(directory: str) -> list[str]:
    names = ['.', '..']

    try:
        with os.scandir(directory) as it:
            names += sorted(entry.name for entry in it if entry.is_dir())

    except OSError:
        pass

    return names


def main() -> None:
    # popup width and list width (excluding preview) in percentage, and the directory to list
    popup_ratio, list_ratio = (int(arg) for arg in sys.argv[1:3])
    directory = os.path.abspath(sys.argv[3] if len(sys.argv) > 3 else '.')

    entries = []

    for name in directories(directory):
        # logical path like `cd`, '..' of a symlinked directory goes back to where it was entered from
        path = os.path.normpath(os.path.join(directory, name))

        if '\t' in path or '\n' in path:
            continue

        try:
            st = os.stat(path)

        except OSError:
            continue

        entries.append((path, name, stat.filemode(st.st_mode), human_size(st.st_size), *modify_time(st.st_mtime)))

    length = [max(len(entry[i]) for entry in entries) for i in range(2, 6 + 1)]

    line_length = int(int(window_width() * popup_ratio / 100) * list_ratio / 100) - 5
    name_length = line_length - (sum(length) + len(length))

    if name_length < 4:
        print('\tERROR: window width not enough')

        exit(1)

    color = ['', GREEN, BLUE, BLUE, BLUE]

    for entry in entries:
        name = entry[1]

        if display_width(name) > name_length:
            while display_width(name) + 3 > name_length:
                name = name[:-1]

            name += '...'

        padding = ' ' * (name_length - display_width(name))
        postfix = ' '.join([f'{_color}{_entry:>{_length}}{RESET}' for _color, _entry, _length in zip(color, entry[2:], length)])

        # first field is the absolute path, hidden from fzf by --with-nth
        print(f'{entry[0]}\t{BLUE}{name}{RESET}{padding} {postfix}')


if __name__ == '__main__':
    main()
