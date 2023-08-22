#
# IMPORTS
#
from io import FileIO
from os import stat
from sys import argv


#
# CONSTANTS
#
EPS = 10**(-5)  # acceptable relative error margin (0.001%)


#
# CODE
#
def relativeErr(measured: float, reference: float) -> float:
    """
    I calculate the relative error between a measured and a reference value.
    """
    return abs(measured-reference)/reference


def getMaxRelativeError(measuredFile: FileIO, referenceFile: FileIO) -> float:
    """
    I read two polybench output files and calculate their larges relative error.

    :param measuredFile: file with measured values
    :param referenceFile: file with real values

    :returns: largest relative error between files
    """
    # set errors array
    errs = [0.0]

    # iterate through each line
    while True:

        # get flot values from files
        measuredValues = measuredFile.readline().split()
        referenceValues = referenceFile.readline().split()

        if len(measuredValues) != len(referenceValues):
            raise ValueError('Files differ in the amount of output values.')

        # reached end of file: stop
        if not measuredValues or not referenceValues:
            break

        # convert value to float
        measuredValues = map(float, measuredValues)
        referenceValues = map(float, referenceValues)

        # bind target values to respective reference values
        bindedList = zip(measuredValues, referenceValues)

        # compare each value in the current line
        for measured, reference in bindedList:
            if measured != reference:
                errs += [relativeErr(measured, reference)]

    # return max relative error
    return max(errs)


def checkThreshold(error: float) -> None:
    """
    I check if the relative error is acceptable

    :params error: largest relative error
    """
    print(f'[INFO] Largest relative error was {error:.2e}')
    if error <= EPS:
        print(f'[OK] Errors within threshold (smaller than {EPS:.2e})')
    else:
        print(f'[ERROR] Threshold exceeded ({error:.2e} > {EPS:.2e})')


#
# ENTRYPOINT
#
if __name__ == '__main__':

    # fetch max relative error between files
    with open(argv[1], 'r') as measured, open(argv[2], 'r') as reference:
        maxErr = getMaxRelativeError(measured, reference)

    # check if errors are within the threshold
    checkThreshold(maxErr)
