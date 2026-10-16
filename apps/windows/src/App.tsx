import React, { useState, useEffect, useRef } from "react";
import { updaterService, UpdateInfo } from "./services/updater";
import {
  ArrowUpRight,
  ArrowDownLeft,
  QrCode,
  Laptop,
  Smartphone,
  HardDrive,
  RefreshCw,
  Settings,
  Bell,
  CheckCircle,
  Pause,
  Play,
  X,
  FileText,
  Clock,
  ShieldCheck,
  Zap,
} from "lucide-react";

export function App() {
  const [activeTab, setActiveTab] = useState<
    "dashboard" | "transfer" | "qr" | "history" | "updates" | "settings"
  >("dashboard");

  // In-App Update States
  const [updateInfo, setUpdateInfo] = useState<UpdateInfo | null>(null);
  const [isCheckingUpdate, setIsCheckingUpdate] = useState(false);
  const [showUpdateModal, setShowUpdateModal] = useState(false);
  const [isDownloadingUpdate, setIsDownloadingUpdate] = useState(false);
  const [updateDownloadProgress, setUpdateDownloadProgress] = useState(0);

  // Active Transfer State (Dynamic Island Pill)
  const [activeTransfer, setActiveTransfer] = useState<{
    fileName: string;
    progress: number;
    speed: string;
    direction: "upload" | "download";
    isPaused: boolean;
  } | null>({
    fileName: "presentation_slides_4k.zip",
    progress: 68,
    speed: "18.4 MB/s",
    direction: "download",
    isPaused: false,
  });

  // QR Pairing Session State (5-minute countdown)
  const [qrCodeData, setQrCodeData] = useState("PIXELDROP-PAIR-7821-SESSION");
  const [verificationCode, setVerificationCode] = useState("849 201");
  const [countdownSeconds, setCountdownSeconds] = useState(300); // 5 minutes

  // Transfer Queue & Drag-and-Drop
  const [isDragging, setIsDragging] = useState(false);
  const [recentTransfers, setRecentTransfers] = useState([
    { id: "1", name: "Camera_RAW_2026.dng", size: "48.2 MB", status: "Completed", time: "2m ago" },
    { id: "2", name: "PixelDrop_Android.apk", size: "24.5 MB", status: "Completed", time: "15m ago" },
    { id: "3", name: "client_database_export.sql", size: "128.0 MB", status: "Completed", time: "1h ago" },
  ]);

  // Check for updates on startup
  useEffect(() => {
    checkUpdates();
  }, []);

  // 5-minute countdown timer for QR
  useEffect(() => {
    const timer = setInterval(() => {
      setCountdownSeconds((prev) => {
        if (prev <= 1) {
          // Generate new token & reset 5 mins
          setVerificationCode(
            Math.floor(100000 + Math.random() * 900000)
              .toString()
              .replace(/(\d{3})(\d{3})/, "$1 $2")
          );
          return 300;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const checkUpdates = async () => {
    setIsCheckingUpdate(true);
    const info = await updaterService.checkForUpdates();
    setUpdateInfo(info);
    setIsCheckingUpdate(false);

    if (info.available) {
      setShowUpdateModal(true);
      updaterService.notifyUpdateAvailable(info);
    }
  };

  const handleStartInAppUpdate = () => {
    setIsDownloadingUpdate(true);
    setUpdateDownloadProgress(0);

    // Simulate in-app binary stream download with progress
    const interval = setInterval(() => {
      setUpdateDownloadProgress((prev) => {
        if (prev >= 100) {
          clearInterval(interval);
          setTimeout(() => {
            alert("Update downloaded successfully! Installing and restarting PIXELDROP...");
            setIsDownloadingUpdate(false);
            setShowUpdateModal(false);
          }, 800);
          return 100;
        }
        return prev + 10;
      });
    }, 300);
  };

  const formatCountdown = (secs: number) => {
    const m = Math.floor(secs / 60);
    const s = secs % 60;
    return `${m}:${s < 10 ? "0" : ""}${s}`;
  };

  return (
    <div className="flex h-screen w-screen bg-[#080808] text-[#FFFFFF] select-none font-sans overflow-hidden">
      {/* SIDEBAR NAVIGATION */}
      <aside className="w-64 bg-[#101015] border-r border-[#22222E] flex flex-col justify-between p-4 z-20">
        <div>
          {/* Logo & App Name */}
          <div className="flex items-center gap-3 px-2 py-3 mb-6">
            <div className="w-10 h-10 rounded-lg bg-[#FF6338] flex items-center justify-center shadow-[0_0_20px_rgba(255,99,56,0.4)]">
              <Zap className="w-6 h-6 text-black fill-black" />
            </div>
            <div>
              <h1 className="text-lg font-bold tracking-wider text-white">PIXELDROP</h1>
              <span className="text-xs text-[#FF6338] font-mono tracking-widest font-semibold">
                v{updaterService.getCurrentVersion()}
              </span>
            </div>
          </div>

          {/* Navigation Links */}
          <nav className="space-y-1.5">
            {[
              { id: "dashboard", label: "Dashboard", icon: HardDrive },
              { id: "transfer", label: "File Transfer", icon: ArrowUpRight },
              { id: "qr", label: "QR Connect", icon: QrCode },
              { id: "history", label: "Transfer History", icon: Clock },
              {
                id: "updates",
                label: "Updates Center",
                icon: RefreshCw,
                badge: updateInfo?.available ? "NEW" : undefined,
              },
              { id: "settings", label: "Settings", icon: Settings },
            ].map((item) => {
              const Icon = item.icon;
              const isActive = activeTab === item.id;
              return (
                <button
                  key={item.id}
                  onClick={() => setActiveTab(item.id as any)}
                  className={`w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all ${
                    isActive
                      ? "bg-[#1C1C26] text-[#FF6338] border border-[#FF633844] shadow-[0_0_15px_rgba(255,99,56,0.15)]"
                      : "text-[#A1A1AA] hover:bg-[#15151E] hover:text-white"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <Icon className={`w-4 h-4 ${isActive ? "text-[#FF6338]" : ""}`} />
                    <span>{item.label}</span>
                  </div>
                  {item.badge && (
                    <span className="px-1.5 py-0.5 text-[10px] font-mono font-bold bg-[#FF6338] text-black rounded-md animate-pulse">
                      {item.badge}
                    </span>
                  )}
                </button>
              );
            })}
          </nav>
        </div>

        {/* Device Status Card */}
        <div className="p-3 bg-[#15151E] border border-[#22222E] rounded-xl text-xs space-y-2">
          <div className="flex items-center justify-between text-[#A1A1AA]">
            <span>Local Device</span>
            <span className="inline-block w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
          </div>
          <div className="flex items-center gap-2 font-mono text-white">
            <Laptop className="w-4 h-4 text-[#FF6338]" />
            <span className="truncate">Windows-PC (Ready)</span>
          </div>
          <div className="text-[11px] text-[#71717A] font-mono">
            Direct LAN / Wi-Fi Active
          </div>
        </div>
      </aside>

      {/* MAIN CONTENT AREA */}
      <main className="flex-1 flex flex-col h-full overflow-hidden bg-[#080808] relative">
        {/* TOP BAR / DYNAMIC ISLAND INDICATOR */}
        <header className="h-16 border-b border-[#1A1A24] px-8 flex items-center justify-between z-10">
          <div className="text-sm font-medium text-[#A1A1AA]">
            {activeTab.toUpperCase()}
          </div>

          {/* DYNAMIC ISLAND TRANSFER PILL */}
          {activeTransfer && (
            <div className="flex items-center gap-4 bg-[#14141E] border border-[#FF633844] px-4 py-2 rounded-full shadow-[0_0_20px_rgba(255,99,56,0.25)] animate-in fade-in zoom-in duration-300">
              <div className="w-2.5 h-2.5 rounded-full bg-[#FF6338] animate-ping" />
              <div className="text-xs">
                <span className="text-[#A1A1AA]">
                  {activeTransfer.direction === "download" ? "Receiving: " : "Sending: "}
                </span>
                <span className="font-mono text-white font-semibold">
                  {activeTransfer.fileName}
                </span>
                <span className="text-[#FF6338] font-mono font-bold ml-2">
                  {activeTransfer.progress}%
                </span>
                <span className="text-[#71717A] font-mono ml-1 text-[11px]">
                  ({activeTransfer.speed})
                </span>
              </div>
              <div className="flex items-center gap-1.5 ml-2">
                <button
                  onClick={() =>
                    setActiveTransfer({
                      ...activeTransfer,
                      isPaused: !activeTransfer.isPaused,
                    })
                  }
                  className="p-1 hover:bg-[#22222E] rounded-md text-[#A1A1AA] hover:text-white"
                >
                  {activeTransfer.isPaused ? (
                    <Play className="w-3.5 h-3.5 text-[#FF6338]" />
                  ) : (
                    <Pause className="w-3.5 h-3.5" />
                  )}
                </button>
                <button
                  onClick={() => setActiveTransfer(null)}
                  className="p-1 hover:bg-[#22222E] rounded-md text-[#A1A1AA] hover:text-white"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          )}

          {/* Top Right Actions */}
          <div className="flex items-center gap-3">
            <button
              onClick={() => checkUpdates()}
              title="Check Updates"
              className="p-2 bg-[#14141E] border border-[#22222E] rounded-xl hover:border-[#FF6338] text-[#A1A1AA] hover:text-[#FF6338] transition-all"
            >
              <RefreshCw
                className={`w-4 h-4 ${isCheckingUpdate ? "animate-spin text-[#FF6338]" : ""}`}
              />
            </button>
            <button className="p-2 bg-[#14141E] border border-[#22222E] rounded-xl text-[#A1A1AA] hover:text-white">
              <Bell className="w-4 h-4" />
            </button>
          </div>
        </header>

        {/* CONTENT TABS */}
        <div className="flex-1 overflow-y-auto p-8">
          {/* TAB 1: DASHBOARD */}
          {activeTab === "dashboard" && (
            <div className="max-w-5xl mx-auto space-y-8">
              {/* Primary Send & Receive Buttons */}
              <div className="grid grid-cols-2 gap-6">
                <button
                  onClick={() => setActiveTab("transfer")}
                  className="group relative p-6 bg-[#12121A] hover:bg-[#181822] border-2 border-[#FF633844] hover:border-[#FF6338] rounded-2xl flex flex-col justify-between h-48 transition-all shadow-[0_0_30px_rgba(255,99,56,0.1)] hover:shadow-[0_0_35px_rgba(255,99,56,0.3)] text-left"
                >
                  <div className="w-12 h-12 rounded-xl bg-[#FF6338] flex items-center justify-center text-black shadow-lg">
                    <ArrowUpRight className="w-6 h-6 stroke-[2.5]" />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold text-white group-hover:text-[#FF6338] transition-colors">
                      Send Files
                    </h2>
                    <p className="text-xs text-[#A1A1AA] mt-1 font-mono">
                      Fast local Wi-Fi or secure cloud link transfer
                    </p>
                  </div>
                </button>

                <button
                  onClick={() => setActiveTab("qr")}
                  className="group relative p-6 bg-[#12121A] hover:bg-[#181822] border-2 border-[#262636] hover:border-[#00F0FF] rounded-2xl flex flex-col justify-between h-48 transition-all shadow-[0_0_20px_rgba(0,0,0,0.5)] text-left"
                >
                  <div className="w-12 h-12 rounded-xl bg-[#00F0FF] flex items-center justify-center text-black shadow-lg">
                    <ArrowDownLeft className="w-6 h-6 stroke-[2.5]" />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold text-white group-hover:text-[#00F0FF] transition-colors">
                      Receive Files
                    </h2>
                    <p className="text-xs text-[#A1A1AA] mt-1 font-mono">
                      Generate QR code or provide 6-digit PIN code
                    </p>
                  </div>
                </button>
              </div>

              {/* Drag-and-Drop Zone */}
              <div
                onDragOver={(e) => {
                  e.preventDefault();
                  setIsDragging(true);
                }}
                onDragLeave={() => setIsDragging(false)}
                onDrop={(e) => {
                  e.preventDefault();
                  setIsDragging(false);
                  const files = Array.from(e.dataTransfer.files);
                  if (files.length > 0) {
                    setActiveTransfer({
                      fileName: files[0].name,
                      progress: 10,
                      speed: "24.1 MB/s",
                      direction: "upload",
                      isPaused: false,
                    });
                  }
                }}
                className={`border-2 border-dashed rounded-2xl p-10 flex flex-col items-center justify-center transition-all ${
                  isDragging
                    ? "border-[#FF6338] bg-[#FF633811] scale-[1.01]"
                    : "border-[#282838] bg-[#0E0E14] hover:border-[#38384E]"
                }`}
              >
                <div className="w-14 h-14 rounded-full bg-[#181822] flex items-center justify-center text-[#FF6338] mb-4">
                  <ArrowUpRight className="w-6 h-6 animate-bounce" />
                </div>
                <h3 className="text-base font-semibold text-white">
                  Drag and drop any files here
                </h3>
                <p className="text-xs text-[#A1A1AA] mt-1 font-mono">
                  Photos, Videos, Documents, ZIP, APK (Auto-encrypted SHA-256)
                </p>
              </div>

              {/* Recent Transfers Table */}
              <div className="bg-[#12121A] border border-[#22222E] rounded-2xl p-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-sm font-bold tracking-wider text-white">
                    RECENT TRANSFERS
                  </h3>
                  <button
                    onClick={() => setActiveTab("history")}
                    className="text-xs text-[#FF6338] hover:underline font-mono"
                  >
                    View All
                  </button>
                </div>
                <div className="divide-y divide-[#1F1F2C]">
                  {recentTransfers.map((item) => (
                    <div
                      key={item.id}
                      className="py-3 flex items-center justify-between text-xs"
                    >
                      <div className="flex items-center gap-3">
                        <FileText className="w-4 h-4 text-[#FF6338]" />
                        <span className="font-mono text-white font-medium">
                          {item.name}
                        </span>
                      </div>
                      <div className="flex items-center gap-6 font-mono text-[#A1A1AA]">
                        <span>{item.size}</span>
                        <span className="text-emerald-400 flex items-center gap-1">
                          <CheckCircle className="w-3.5 h-3.5" />
                          {item.status}
                        </span>
                        <span className="text-[#71717A]">{item.time}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: QR CONNECT (5-MINUTE EXPIRING VERIFICATION) */}
          {activeTab === "qr" && (
            <div className="max-w-2xl mx-auto bg-[#12121A] border border-[#22222E] rounded-2xl p-8 space-y-6 text-center">
              <div>
                <h2 className="text-2xl font-bold text-white">QR Pairing Session</h2>
                <p className="text-xs text-[#A1A1AA] mt-1 font-mono">
                  Scan with PIXELDROP Android to start peer-to-peer file transfer
                </p>
              </div>

              {/* Simulated Pixel QR Block */}
              <div className="w-64 h-64 mx-auto p-4 bg-white rounded-2xl flex items-center justify-center shadow-[0_0_30px_rgba(255,255,255,0.15)]">
                <div className="w-full h-full border-4 border-black border-dashed flex flex-col items-center justify-center text-black">
                  <QrCode className="w-32 h-32 text-black" />
                  <span className="text-[10px] font-mono font-bold mt-2">
                    PIXELDROP-PAIR
                  </span>
                </div>
              </div>

              {/* 6-Digit Verification PIN & 5-Minute Timer */}
              <div className="bg-[#181824] border border-[#2E2E40] rounded-xl p-4 max-w-sm mx-auto">
                <div className="text-xs text-[#A1A1AA] font-mono">
                  VERIFICATION PIN CODE
                </div>
                <div className="text-3xl font-mono font-extrabold text-[#FF6338] tracking-widest my-2">
                  {verificationCode}
                </div>
                <div className="text-xs text-[#71717A] font-mono flex items-center justify-center gap-1.5">
                  <Clock className="w-3.5 h-3.5 text-[#FF6338]" />
                  Expires in:{" "}
                  <span className="text-white font-bold">
                    {formatCountdown(countdownSeconds)}
                  </span>
                </div>
              </div>

              <div className="text-xs text-[#71717A] max-w-md mx-auto">
                Both devices must verify this 6-digit code. Pairing sessions automatically
                revoke after 5 minutes or upon manual termination.
              </div>
            </div>
          )}

          {/* TAB 3: UPDATES CENTER */}
          {activeTab === "updates" && (
            <div className="max-w-3xl mx-auto space-y-6">
              <div className="bg-[#12121A] border border-[#22222E] rounded-2xl p-6 flex items-center justify-between">
                <div>
                  <h2 className="text-xl font-bold text-white">Updates Center</h2>
                  <p className="text-xs text-[#A1A1AA] mt-1 font-mono">
                    Direct in-app binary updates backed by GitHub Releases
                  </p>
                </div>
                <button
                  onClick={() => checkUpdates()}
                  disabled={isCheckingUpdate}
                  className="px-4 py-2 bg-[#FF6338] hover:bg-[#FF7A54] text-black font-bold rounded-xl text-xs font-mono flex items-center gap-2 shadow-[0_0_20px_rgba(255,99,56,0.3)] disabled:opacity-50"
                >
                  <RefreshCw
                    className={`w-4 h-4 ${isCheckingUpdate ? "animate-spin" : ""}`}
                  />
                  {isCheckingUpdate ? "CHECKING GITHUB..." : "CHECK NOW"}
                </button>
              </div>

              {/* Version Comparison Card */}
              <div className="grid grid-cols-2 gap-4">
                <div className="p-5 bg-[#12121A] border border-[#22222E] rounded-xl space-y-1">
                  <span className="text-xs text-[#71717A] font-mono">INSTALLED VERSION</span>
                  <div className="text-2xl font-mono font-bold text-white">
                    v{updaterService.getCurrentVersion()}
                  </div>
                  <span className="text-xs text-emerald-400 font-mono">
                    ✓ Running locally
                  </span>
                </div>

                <div className="p-5 bg-[#12121A] border border-[#22222E] rounded-xl space-y-1">
                  <span className="text-xs text-[#71717A] font-mono">
                    LATEST GITHUB RELEASE
                  </span>
                  <div className="text-2xl font-mono font-bold text-[#FF6338]">
                    v{updateInfo?.latestVersion || updaterService.getCurrentVersion()}
                  </div>
                  <span className="text-xs text-[#A1A1AA] font-mono">
                    {updateInfo?.available ? "🚀 New update available!" : "✓ Up to date"}
                  </span>
                </div>
              </div>

              {/* Repository Source Info */}
              <div className="p-5 bg-[#12121A] border border-[#22222E] rounded-xl space-y-3">
                <h3 className="text-sm font-bold text-white font-mono">
                  RELEASE SOURCE REPOSITORY
                </h3>
                <div className="text-xs text-[#A1A1AA] font-mono bg-[#0A0A0F] p-3 rounded-lg border border-[#1F1F2C]">
                  https://github.com/MEYYYNASH/TRANSFERAPP.git
                </div>
                <p className="text-xs text-[#71717A]">
                  When a new release tag is pushed to GitHub, PIXELDROP immediately downloads
                  and installs the update package in-app without needing a browser.
                </p>
              </div>
            </div>
          )}

          {/* TAB 4: SETTINGS & GENERAL */}
          {activeTab === "settings" && (
            <div className="max-w-2xl mx-auto bg-[#12121A] border border-[#22222E] rounded-2xl p-6 space-y-6">
              <h2 className="text-xl font-bold text-white">Application Settings</h2>
              <div className="space-y-4 divide-y divide-[#1F1F2C] text-sm">
                <div className="pt-3 flex items-center justify-between">
                  <div>
                    <div className="font-medium text-white">Auto-Check for Updates</div>
                    <div className="text-xs text-[#A1A1AA]">
                      Periodically query GitHub for new releases
                    </div>
                  </div>
                  <input type="checkbox" defaultChecked className="accent-[#FF6338]" />
                </div>
                <div className="pt-3 flex items-center justify-between">
                  <div>
                    <div className="font-medium text-white">In-App Silent Update Flow</div>
                    <div className="text-xs text-[#A1A1AA]">
                      Install and relaunch without opening browser
                    </div>
                  </div>
                  <input type="checkbox" defaultChecked className="accent-[#FF6338]" />
                </div>
                <div className="pt-3 flex items-center justify-between">
                  <div>
                    <div className="font-medium text-white">Local Wi-Fi P2P Mode</div>
                    <div className="text-xs text-[#A1A1AA]">
                      Bypass cloud storage when devices share LAN
                    </div>
                  </div>
                  <input type="checkbox" defaultChecked className="accent-[#FF6338]" />
                </div>
              </div>
            </div>
          )}
        </div>
      </main>

      {/* IN-APP UPDATE MODAL (TRIGGERED WHEN GITHUB HAS NEW RELEASE) */}
      {showUpdateModal && updateInfo && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="w-full max-w-md bg-[#14141E] border-2 border-[#FF6338] rounded-2xl p-6 space-y-5 shadow-[0_0_50px_rgba(255,99,56,0.3)] animate-in fade-in zoom-in duration-200">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="w-3 h-3 rounded-full bg-[#FF6338] animate-ping" />
                <h3 className="text-lg font-bold text-white">New Update Available!</h3>
              </div>
              <button
                onClick={() => setShowUpdateModal(false)}
                className="text-[#71717A] hover:text-white"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="bg-[#0A0A0F] border border-[#22222E] rounded-xl p-3.5 space-y-1 font-mono text-xs">
              <div className="flex justify-between text-[#A1A1AA]">
                <span>Current: v{updateInfo.currentVersion}</span>
                <span className="text-[#FF6338] font-bold">
                  Target: v{updateInfo.latestVersion}
                </span>
              </div>
              <div className="text-[#71717A] text-[11px] pt-1">
                Release Notes: {updateInfo.releaseNotes}
              </div>
            </div>

            {/* In-App Download Progress */}
            {isDownloadingUpdate ? (
              <div className="space-y-2">
                <div className="flex justify-between text-xs font-mono text-[#A1A1AA]">
                  <span>Downloading in-app update...</span>
                  <span className="text-[#FF6338] font-bold">
                    {updateDownloadProgress}%
                  </span>
                </div>
                <div className="w-full h-2.5 bg-[#22222E] rounded-full overflow-hidden">
                  <div
                    className="h-full bg-[#FF6338] transition-all duration-300 shadow-[0_0_10px_#FF6338]"
                    style={{ width: `${updateDownloadProgress}%` }}
                  />
                </div>
              </div>
            ) : (
              <div className="flex items-center gap-3">
                <button
                  onClick={handleStartInAppUpdate}
                  className="flex-1 py-2.5 bg-[#FF6338] hover:bg-[#FF7A54] text-black font-bold rounded-xl text-xs font-mono shadow-[0_0_20px_rgba(255,99,56,0.4)] transition-all"
                >
                  UPDATE NOW (IN-APP)
                </button>
                <button
                  onClick={() => setShowUpdateModal(false)}
                  className="px-4 py-2.5 bg-[#1F1F2C] hover:bg-[#282838] text-[#A1A1AA] hover:text-white rounded-xl text-xs font-mono"
                >
                  LATER
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
