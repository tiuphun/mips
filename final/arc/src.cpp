// An equivalent CPP program.
#include <iostream>
#include <vector>
#include <iomanip>
using namespace std;

string input;
vector<vector<char> > disk1;
vector<vector<char> > disk2;
vector<vector<char> > disk3;

char calculate_parity(char a, char b) {
    return a ^ b;
}

void print() {
    int max_size = max(max(disk1.size(), disk2.size()), disk3.size());
    printf("Disk 1\t\t\tDisk2\t\t\tDisk3\n");
    printf("---------------\t\t---------------\t\t---------------\n");

    for (int i = 0; i < max_size; i++) {
        if (i < disk1.size()) {
            cout << "[";
            for (int j = 0; j < disk1[i].size(); j++) {
                if ((i % 3) == 2) {
                    cout << hex << setw(2) << setfill('0') << static_cast<unsigned int>(disk1[i][j]);
                    if (j != disk1[i].size() - 1) cout << ", ";
                } else {
                    cout << disk1[i][j];
                }
            }
            cout << "]";
        }
        cout << "\t\t";

        if (i < disk2.size()) {
            cout << "[";
            for (int j = 0; j < disk2[i].size(); j++) {
                if ((i % 3) == 1) {
                    cout << hex << setw(2) << setfill('0') << static_cast<unsigned int>(disk2[i][j]);
                    if (j != disk2[i].size() - 1) cout << ", ";
                } else {
                    cout << disk2[i][j];
                }
            }
            cout << "]";
        }
        cout << "\t\t";

        if (i < disk3.size()) {
            cout << "[";
            for (int j = 0; j < disk3[i].size(); j++) {
                if ((i % 3) == 0) {
                    cout << hex << setw(2) << setfill('0') << static_cast<unsigned int>(disk3[i][j]);
                    if (j != disk3[i].size() - 1) cout << ", ";
                } else {
                    cout << disk3[i][j];
                }
            }
            cout << "]";
        }
        cout << "\n";
    }

}

int main(int argc, char const *argv[]) {
    do {
        cin >> input;
    } while (input.length() % 8 != 0);

    for (int i = 0; i < input.length(); i += 8) {
        vector<char> group1, group2, parityGroup;
        for (int j = 0; j < 4; j++) {
            group1.push_back(input[i+j]);
            group2.push_back(input[i+j+4]);
            char parity = calculate_parity(input[i+j], input[i+j+4]);
            parityGroup.push_back(parity);
        }
        switch ((i / 8) % 3) {
            case 0:
                disk1.push_back(group1);
                disk2.push_back(group2);
                disk3.push_back(parityGroup);
                break;
            case 1:
                disk1.push_back(group1);
                disk3.push_back(group2);
                disk2.push_back(parityGroup);
                break;
            case 2:
                disk2.push_back(group1);
                disk3.push_back(group2);
                disk1.push_back(parityGroup);
                break;
        }
    }

    print();
    return 0;
}