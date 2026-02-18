const int magic = 0x70_64_62_78;
const int pdbxVersion = 0x00_01;

// === Header Fields Sizes ===

const int magicSize = 4;
const int versionSize = 2;
const int indexLengthSize = 4;
const int saltSize = 16;
const int indexIvSize = 12;

// === Header Fields Offsets ===

const int magicOffset = 0;
const int versionOffset = 4;
const int indexLengthOffset = 6;
const int saltOffset = 10;
const int indexIvOffset = 26;

const int headerSize =
    magicSize + versionSize + indexLengthSize + saltSize + indexIvSize;
