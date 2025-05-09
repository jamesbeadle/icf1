import * as FlagIcons from "svelte-flag-icons";
import type { Neuron } from "../../../../declarations/backend/backend.did";

export function uint8ArrayToBase64(bytes: Uint8Array): string {
  const binary = Array.from(bytes)
    .map((byte) => String.fromCharCode(byte))
    .join("");
  return btoa(binary);
}

export function formatUnixDateToReadable(unixNano: bigint) {
  const date = new Date(Number(unixNano) / 1000000);
  const options: Intl.DateTimeFormatOptions = {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  };

  return new Intl.DateTimeFormat("en-UK", options).format(date);
}

export function formatUnixDateToSmallReadable(unixNano: bigint) {
  const date = new Date(Number(unixNano) * 1000);
  const options: Intl.DateTimeFormatOptions = {
    year: "numeric",
    month: "short",
    day: "numeric",
  };

  return new Intl.DateTimeFormat("en-UK", options).format(date);
}

export function getCountdownTime(unixNano: number) {
  const targetDate = new Date(unixNano / 1000000);
  const now = new Date();
  const diff = targetDate.getTime() - now.getTime();

  if (diff <= 0) {
    return { days: 0, hours: 0, minutes: 0 };
  }

  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
  const minutes = Math.floor((diff / (1000 * 60)) % 60);

  return { days, hours, minutes };
}

export function replacer(key: string, value: bigint) {
  if (typeof value === "bigint") {
    return value.toString();
  } else {
    return value;
  }
}

export function formatUnixTimeToTime(unixTimeNano: number): string {
  const unixTimeMillis = unixTimeNano / 1000000;
  const date = new Date(unixTimeMillis);

  let hours = date.getHours();
  const minutes = date.getMinutes();
  const ampm = hours >= 12 ? "PM" : "AM";
  hours = hours % 12;
  hours = hours ? hours : 12;
  const minutesStr = minutes < 10 ? "0" + minutes : minutes;

  return `${hours}:${minutesStr} ${ampm}`;
}

export function formatUnixToDateInputValue(unixNano: number) {
  const date = new Date(unixNano / 1000000);
  const year = date.getFullYear();
  let month = (date.getMonth() + 1).toString();
  let day = date.getDate().toString();

  month = month.length < 2 ? "0" + month : month;
  day = day.length < 2 ? "0" + day : day;

  return `${year}-${month}-${day}`;
}

export function convertDateInputToUnixNano(dateString: string): bigint {
  const dateParts = dateString.split("-");
  if (dateParts.length !== 3) {
    throw new Error("Invalid date format. Expected YYYY-MM-DD");
  }

  const year = parseInt(dateParts[0], 10);
  const month = parseInt(dateParts[1], 10) - 1;
  const day = parseInt(dateParts[2], 10);

  const date = new Date(year, month, day);
  const unixTimeMillis = date.getTime();
  return BigInt(unixTimeMillis) * BigInt(1000000);
}

export function convertDateTimeInputToUnixNano(dateTimeString: string): bigint {
  const [datePart, timePart] = dateTimeString.split("T");

  const dateParts = datePart.split("-");
  if (dateParts.length !== 3) {
    throw new Error("Invalid date format. Expected YYYY-MM-DD");
  }
  const year = parseInt(dateParts[0], 10);
  const month = parseInt(dateParts[1], 10) - 1;
  const day = parseInt(dateParts[2], 10);

  let hours = 0,
    minutes = 0,
    seconds = 0;
  if (timePart) {
    const timeParts = timePart.split(":");
    hours = parseInt(timeParts[0], 10);
    minutes = parseInt(timeParts[1], 10);
    if (timeParts.length === 3) {
      seconds = parseInt(timeParts[2], 10);
    }
  }

  const date = new Date(year, month, day, hours, minutes, seconds);
  const unixTimeMillis = date.getTime();
  return BigInt(unixTimeMillis) * BigInt(1000000);
}

export function convertDateToReadable(nanoseconds: number): string {
  const milliseconds = nanoseconds / 1e6;
  const date = new Date(milliseconds);
  return date.toLocaleDateString("en-GB");
}

export function calculateAgeFromNanoseconds(nanoseconds: number) {
  const milliseconds = nanoseconds / 1e6;
  const birthDate = new Date(milliseconds);
  const today = new Date();

  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDifference = today.getMonth() - birthDate.getMonth();

  if (
    monthDifference < 0 ||
    (monthDifference === 0 && today.getDate() < birthDate.getDate())
  ) {
    age--;
  }

  return age;
}

export function getFlagComponent(countryId: number) {
  switch (countryId) {
    case 1:
      return FlagIcons.Af;
    case 2:
      return FlagIcons.Al;
    case 3:
      return FlagIcons.Dz;
    case 4:
      return FlagIcons.Ad;
    case 5:
      return FlagIcons.Ao;
    case 6:
      return FlagIcons.Ag;
    case 7:
      return FlagIcons.Ar;
    case 8:
      return FlagIcons.Am;
    case 9:
      return FlagIcons.Au;
    case 10:
      return FlagIcons.At;
    case 11:
      return FlagIcons.Az;
    case 12:
      return FlagIcons.Bs;
    case 13:
      return FlagIcons.Bh;
    case 14:
      return FlagIcons.Bd;
    case 15:
      return FlagIcons.Bb;
    case 16:
      return FlagIcons.By;
    case 17:
      return FlagIcons.Be;
    case 18:
      return FlagIcons.Bz;
    case 20:
      return FlagIcons.Bt;
    case 21:
      return FlagIcons.Bo;
    case 22:
      return FlagIcons.Ba;
    case 23:
      return FlagIcons.Bw;
    case 24:
      return FlagIcons.Br;
    case 25:
      return FlagIcons.Bn;
    case 26:
      return FlagIcons.Bg;
    case 27:
      return FlagIcons.Bf;
    case 28:
      return FlagIcons.Bi;
    case 29:
      return FlagIcons.Cv;
    case 30:
      return FlagIcons.Kh;
    case 31:
      return FlagIcons.Cm;
    case 32:
      return FlagIcons.Ca;
    case 33:
      return FlagIcons.Cf;
    case 34:
      return FlagIcons.Td;
    case 35:
      return FlagIcons.Cl;
    case 36:
      return FlagIcons.Cn;
    case 37:
      return FlagIcons.Co;
    case 38:
      return FlagIcons.Km;
    case 39:
      return FlagIcons.Cd;
    case 40:
      return FlagIcons.Cg;
    case 41:
      return FlagIcons.Cr;
    case 42:
      return FlagIcons.Ci;
    case 43:
      return FlagIcons.Hr;
    case 44:
      return FlagIcons.Cu;
    case 45:
      return FlagIcons.Cy;
    case 46:
      return FlagIcons.Cz;
    case 47:
      return FlagIcons.Dk;
    case 48:
      return FlagIcons.Dj;
    case 49:
      return FlagIcons.Dm;
    case 50:
      return FlagIcons.Do;
    case 51:
      return FlagIcons.Ec;
    case 52:
      return FlagIcons.Eg;
    case 53:
      return FlagIcons.Sv;
    case 54:
      return FlagIcons.Gq;
    case 55:
      return FlagIcons.Er;
    case 56:
      return FlagIcons.Ee;
    case 57:
      return FlagIcons.Sz;
    case 58:
      return FlagIcons.Et;
    case 59:
      return FlagIcons.Fj;
    case 60:
      return FlagIcons.Fi;
    case 61:
      return FlagIcons.Fr;
    case 62:
      return FlagIcons.Ga;
    case 63:
      return FlagIcons.Gm;
    case 64:
      return FlagIcons.Ge;
    case 65:
      return FlagIcons.De;
    case 66:
      return FlagIcons.Gh;
    case 67:
      return FlagIcons.Gr;
    case 68:
      return FlagIcons.Gd;
    case 69:
      return FlagIcons.Gt;
    case 70:
      return FlagIcons.Gn;
    case 71:
      return FlagIcons.Gm;
    case 72:
      return FlagIcons.Gy;
    case 73:
      return FlagIcons.Ht;
    case 74:
      return FlagIcons.Hn;
    case 75:
      return FlagIcons.Hu;
    case 76:
      return FlagIcons.Is;
    case 77:
      return FlagIcons.In;
    case 78:
      return FlagIcons.Id;
    case 79:
      return FlagIcons.Ir;
    case 80:
      return FlagIcons.Iq;
    case 81:
      return FlagIcons.Ie;
    case 82:
      return FlagIcons.Il;
    case 83:
      return FlagIcons.It;
    case 84:
      return FlagIcons.Jm;
    case 85:
      return FlagIcons.Jp;
    case 86:
      return FlagIcons.Jo;
    case 87:
      return FlagIcons.Kz;
    case 88:
      return FlagIcons.Ke;
    case 89:
      return FlagIcons.Ki;
    case 90:
      return FlagIcons.Kp;
    case 91:
      return FlagIcons.Kr;
    case 92:
      return FlagIcons.Xk;
    case 93:
      return FlagIcons.Kw;
    case 94:
      return FlagIcons.Kg;
    case 95:
      return FlagIcons.La;
    case 96:
      return FlagIcons.Lv;
    case 97:
      return FlagIcons.Lb;
    case 98:
      return FlagIcons.Ls;
    case 99:
      return FlagIcons.Lr;
    case 100:
      return FlagIcons.Ly;
    case 101:
      return FlagIcons.Li;
    case 102:
      return FlagIcons.Lt;
    case 103:
      return FlagIcons.Lu;
    case 104:
      return FlagIcons.Mg;
    case 105:
      return FlagIcons.Mw;
    case 106:
      return FlagIcons.My;
    case 107:
      return FlagIcons.Mv;
    case 108:
      return FlagIcons.Ml;
    case 109:
      return FlagIcons.Mt;
    case 110:
      return FlagIcons.Mh;
    case 111:
      return FlagIcons.Mr;
    case 112:
      return FlagIcons.Mu;
    case 113:
      return FlagIcons.Mx;
    case 114:
      return FlagIcons.Fm;
    case 115:
      return FlagIcons.Md;
    case 116:
      return FlagIcons.Mc;
    case 117:
      return FlagIcons.Mn;
    case 118:
      return FlagIcons.Me;
    case 119:
      return FlagIcons.Ma;
    case 120:
      return FlagIcons.Mz;
    case 121:
      return FlagIcons.Mm;
    case 122:
      return FlagIcons.Na;
    case 123:
      return FlagIcons.Nr;
    case 124:
      return FlagIcons.Np;
    case 125:
      return FlagIcons.Nl;
    case 126:
      return FlagIcons.Nz;
    case 127:
      return FlagIcons.Ni;
    case 128:
      return FlagIcons.Ne;
    case 129:
      return FlagIcons.Ne;
    case 130:
      return FlagIcons.Mk;
    case 131:
      return FlagIcons.No;
    case 132:
      return FlagIcons.Om;
    case 133:
      return FlagIcons.Pk;
    case 134:
      return FlagIcons.Pw;
    case 135:
      return FlagIcons.Pa;
    case 136:
      return FlagIcons.Pg;
    case 137:
      return FlagIcons.Py;
    case 138:
      return FlagIcons.Pe;
    case 139:
      return FlagIcons.Ph;
    case 140:
      return FlagIcons.Pl;
    case 141:
      return FlagIcons.Pt;
    case 142:
      return FlagIcons.Qa;
    case 143:
      return FlagIcons.Ro;
    case 144:
      return FlagIcons.Ru;
    case 145:
      return FlagIcons.Rw;
    case 146:
      return FlagIcons.Kn;
    case 147:
      return FlagIcons.Lc;
    case 148:
      return FlagIcons.Vc;
    case 149:
      return FlagIcons.Ws;
    case 150:
      return FlagIcons.Sm;
    case 151:
      return FlagIcons.St;
    case 152:
      return FlagIcons.Sa;
    case 153:
      return FlagIcons.Sn;
    case 154:
      return FlagIcons.Rs;
    case 155:
      return FlagIcons.Sc;
    case 156:
      return FlagIcons.Sl;
    case 157:
      return FlagIcons.Sg;
    case 158:
      return FlagIcons.Sk;
    case 159:
      return FlagIcons.Si;
    case 160:
      return FlagIcons.Sb;
    case 161:
      return FlagIcons.So;
    case 162:
      return FlagIcons.Za;
    case 163:
      return FlagIcons.Ss;
    case 164:
      return FlagIcons.Es;
    case 165:
      return FlagIcons.Lk;
    case 166:
      return FlagIcons.Sd;
    case 167:
      return FlagIcons.Sr;
    case 168:
      return FlagIcons.Se;
    case 169:
      return FlagIcons.Ch;
    case 170:
      return FlagIcons.Sy;
    case 171:
      return FlagIcons.Tw;
    case 172:
      return FlagIcons.Tj;
    case 173:
      return FlagIcons.Tz;
    case 174:
      return FlagIcons.Th;
    case 175:
      return FlagIcons.Tl;
    case 176:
      return FlagIcons.Tg;
    case 177:
      return FlagIcons.To;
    case 178:
      return FlagIcons.Tt;
    case 179:
      return FlagIcons.Tn;
    case 180:
      return FlagIcons.Tr;
    case 181:
      return FlagIcons.Tm;
    case 182:
      return FlagIcons.Tv;
    case 183:
      return FlagIcons.Ug;
    case 184:
      return FlagIcons.Ua;
    case 185:
      return FlagIcons.Ae;
    case 186:
      return FlagIcons.Gb;
    case 187:
      return FlagIcons.Us;
    case 188:
      return FlagIcons.Uy;
    case 189:
      return FlagIcons.Uz;
    case 190:
      return FlagIcons.Vu;
    case 191:
      return FlagIcons.Va;
    case 192:
      return FlagIcons.Ve;
    case 193:
      return FlagIcons.Vn;
    case 194:
      return FlagIcons.Ye;
    case 195:
      return FlagIcons.Zm;
    case 196:
      return FlagIcons.Zw;
    default:
      return null;
  }
}

export function getDateFromBigInt(dateMS: number): string {
  const dateInMilliseconds = Number(dateMS / 1000000);
  const date = new Date(dateInMilliseconds);
  const monthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return `${monthNames[date.getUTCMonth()]} ${date.getUTCFullYear()}`;
}

interface ErrorResponse {
  err: {
    NotFound?: null;
  };
}

interface SuccessResponse {
  ok: any;
}
export function isError(response: any): response is ErrorResponse {
  return response && response.err !== undefined;
}

export function isSuccess(response: any): response is SuccessResponse {
  return response && response.ok !== undefined;
}

export function getMonthFromNumber(month: number): string {
  switch (month) {
    case 1:
      return "January";
    case 2:
      return "February";
    case 3:
      return "March";
    case 4:
      return "April";
    case 5:
      return "May";
    case 6:
      return "June";
    case 7:
      return "July";
    case 8:
      return "August";
    case 9:
      return "September";
    case 10:
      return "October";
    case 11:
      return "November";
    case 12:
      return "December";
  }

  return "";
}

export function getImageURL(blob: any): string {
  let byteArray;
  if (blob && typeof blob === "object" && !Array.isArray(blob)) {
    const values = Object.values(blob);
    if (values.length === 0) {
      return "/default-profile-picture.jpg";
    }
    byteArray = Uint8Array.from(Object.values(blob));
  } else if (Array.isArray(blob) && blob[0] instanceof Uint8Array) {
    byteArray = blob[0];
  } else if (blob instanceof Uint8Array) {
    byteArray = blob;
  } else if (typeof blob === "string") {
    if (blob.startsWith("data:image")) {
      return blob;
    } else if (!blob.startsWith("/default-profile-picture.jpg")) {
      return `data:png;base64,${blob}`;
    }
  }

  if (byteArray) {
    return `data:image/png;base64,${uint8ArrayToBase64(byteArray)}`;
  }

  return "/default-profile-picture.jpg";
}

export function serializeData(data: any): string {
  return JSON.stringify(data, (_, value) =>
    typeof value === "bigint" ? `${value}n` : value,
  );
}

export function deserializeData(data: string): any {
  return JSON.parse(data, (_, value) => {
    if (typeof value === "string" && /^\d+n$/.test(value)) {
      return BigInt(value.slice(0, -1));
    }
    return value;
  });
}

export interface Deferred<T> {
  promise: Promise<T>;
  resolve: (value: T | PromiseLike<T>) => void;
  reject: (reason?: any) => void;
}

export function createDeferred<T>(): Deferred<T> {
  let resolve: (value: T | PromiseLike<T>) => void;
  let reject: (reason?: any) => void;
  const promise = new Promise<T>((res, rej) => {
    resolve = res;
    reject = rej;
  });
  return { promise, resolve: resolve!, reject: reject! };
}

export function getFileExtensionFromFile(file: File): string {
  const filename = file.name;

  const lastIndex = filename.lastIndexOf(".");

  return lastIndex !== -1 ? filename.substring(lastIndex + 1) : "";
}

export function hasMorePages(
  page: bigint,
  pageSize: bigint,
  total: bigint,
): boolean {
  const currentPageBigInt = BigInt(page);
  const endIndex = currentPageBigInt * pageSize;
  return endIndex < total;
}

export function isUsernameValid(username: string): boolean {
  if (!username) {
    return false;
  }

  if (username.length < 3 || username.length > 20) {
    return false;
  }

  return /^[a-zA-Z0-9]+$/.test(username);
}

export function sortByHighestNeuron(a: Neuron, b: Neuron): number {
  return Number(b.cached_neuron_stake_e8s) - Number(a.cached_neuron_stake_e8s);
}
