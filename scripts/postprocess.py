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
        exit(0)

    print(path.group(1).strip())


if __name__ == '__main__':
    main()
