/**
 * In-App Auto Updater Service for PIXELDROP Windows
 * Queries rate-limit-free raw CDN manifest directly without hitting GitHub API limits!
 */

export interface UpdateInfo {
  available: boolean;
  currentVersion: string;
  latestVersion: string;
  releaseNotes: string;
  publishedAt: string;
  downloadUrl?: string;
  fileSize?: number;
}

class InAppUpdaterService {
  private currentVersion = "1.0.2";
  private cdnManifestUrl =
    "https://raw.githubusercontent.com/MEYYYNASH/TRANSFERAPP/main/latest.json";
  private releaseManifestUrl =
    "https://github.com/MEYYYNASH/TRANSFERAPP/releases/latest/download/latest.json";

  public getCurrentVersion(): string {
    return this.currentVersion;
  }

  /**
   * Check for updates using rate-limit-free CDN manifest
   */
  public async checkForUpdates(): Promise<UpdateInfo> {
    const urls = [this.cdnManifestUrl, this.releaseManifestUrl];

    for (const url of urls) {
      try {
        const response = await fetch(url, { cache: "no-cache" });
        if (response.ok) {
          const data = await response.json();
          const latestVersion = (data.version || "1.0.2").replace(/^v/, "");
          const isNewer = this.compareVersions(latestVersion, this.currentVersion) > 0;

          return {
            available: isNewer,
            currentVersion: this.currentVersion,
            latestVersion,
            releaseNotes: data.release_notes || "Performance improvements and bug fixes.",
            publishedAt: data.release_date || new Date().toISOString(),
            downloadUrl: data.windows_url,
          };
        }
      } catch (err: any) {
        console.warn(`Manifest check from ${url} failed:`, err.message);
      }
    }

    return {
      available: false,
      currentVersion: this.currentVersion,
      latestVersion: this.currentVersion,
      releaseNotes: "Up to date.",
      publishedAt: new Date().toISOString(),
    };
  }

  public async notifyUpdateAvailable(info: UpdateInfo) {
    try {
      const { isPermissionGranted, requestPermission, sendNotification } =
        await import("@tauri-apps/plugin-notification");

      let permissionGranted = await isPermissionGranted();
      if (!permissionGranted) {
        const permission = await requestPermission();
        permissionGranted = permission === "granted";
      }

      if (permissionGranted) {
        sendNotification({
          title: "🚀 PIXELDROP Update Available!",
          body: `A new version (v${info.latestVersion}) is ready to install inside the app.`,
        });
      }
    } catch {
      if ("Notification" in window && Notification.permission === "granted") {
        new Notification("🚀 PIXELDROP Update Available!", {
          body: `A new version (v${info.latestVersion}) is ready to install inside the app.`,
        });
      }
    }
  }

  public compareVersions(v1: string, v2: string): number {
    const p1 = v1.split(".").map(Number);
    const p2 = v2.split(".").map(Number);
    for (let i = 0; i < Math.max(p1.length, p2.length); i++) {
      const num1 = p1[i] || 0;
      const num2 = p2[i] || 0;
      if (num1 > num2) return 1;
      if (num1 < num2) return -1;
    }
    return 0;
  }
}

export const updaterService = new InAppUpdaterService();
