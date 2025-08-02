import re


def main() -> None:
    try:
        s = input()

    except EOFError:
        return

    if s == '..':
        print('..')

        return

    *_, permission, size, month, day, time = s.split()
    path = re.match(rf'(.+)\s+{permission}\s+{size}\s+{month}\s+{day}\s+{time}', s)

    if path is None:
        exit(1)

    if len(permission) == 0 or len(size) == 0 or len(month) == 0 or len(day) == 0 or len(time) == 0:
        exit(1)

    print(path.group(1).strip())


if __name__ == '__main__':
    main()
