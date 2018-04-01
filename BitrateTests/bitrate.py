import numpy as np
import uncertainties.unumpy as unp
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from uncertainties import correlated_values
from uncertainties import ufloat

def linFit(x,m,b):
    return m*x + b;

inputBRLocal1080p60RemoteOn, measuredBRLocal1080p60RemoteOn = np.genfromtxt("bitrateLocal1080p60wRemoteOn.txt", unpack=True);
inputBRLocal1080p30RemoteOn, measuredBRLocal1080p30RemoteOn = np.genfromtxt("bitrateLocal1080p30wRemoteOn.txt", unpack=True);
inputBRLocal1080p60RemoteOff, measuredBRLocal1080p60RemoteOff = np.genfromtxt("bitrateLocal1080p60wRemoteOff.txt", unpack=True);

params, pcov = curve_fit(linFit, inputBRLocal1080p60RemoteOn / 1000.0, measuredBRLocal1080p60RemoteOn / 1000.0);
params2, pcov2 = curve_fit(linFit, inputBRLocal1080p30RemoteOn[0:15] / 1000.0, measuredBRLocal1080p30RemoteOn[0:15] / 1000.0);
x = np.linspace(0,36);

plt.plot(x , linFit(x, *params), "r-", label="Linear Curve Fit");
plt.plot(inputBRLocal1080p60RemoteOn / 1000.0, measuredBRLocal1080p60RemoteOn / 1000.0, "bx", label="1080p60 w/ Remote On");
#plt.plot(inputBRLocal1080p60RemoteOff / 1000.0, measuredBRLocal1080p60RemoteOff / 1000.0, "cx", label="1080p60 w/ Remote Off");
plt.ylabel("Measured Bitrate / Mbps");
plt.xlabel("Input Bitrate / Mbps");
plt.legend(loc="best");
plt.savefig("bitrate1080p60.pdf");
plt.close();

print("m1 = ", params[0], "; b1 = ", params[1]);

plt.plot(inputBRLocal1080p30RemoteOn[0:15] / 1000.0, measuredBRLocal1080p30RemoteOn[0:15] / 1000.0, "bx", label="1080p30 w/ Remote On");
plt.plot(inputBRLocal1080p30RemoteOn[15:18] / 1000.0, measuredBRLocal1080p30RemoteOn[15:18] / 1000.0, "cx", label="Ran into Bitrate Limiter");

plt.plot(x , linFit(x, *params2), "r-", label="Linear Curve Fit");
plt.ylabel("Measured Bitrate / Mbps");
plt.xlabel("Input Bitrate / Mbps");
plt.legend(loc="best");
plt.xlim(0,36);
plt.savefig("bitrate1080p30.pdf");
plt.close();

print("m2 = ", params2[0], "; b2 = ", params2[1]);
