/**
 * In-App Auto Updater Service for PIXELDROP Windows
 * Queries GitHub Releases directly without opening external browser.
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

export type UpdateProgressCallback = (progress: number, total: number) => void;

class InAppUpdaterService {
  private repoOwner = "MEYYYNASH";
  private repoName = "TRANSFERAPP";
  private currentVersion = "1.0.2";

  public getCurrentVersion(): string {
    return this.currentVersion;
  }

  /**
   * Check GitHub Releases API for new version
   */
  public async checkForUpdates(): Promise<UpdateInfo> {
    try {
      const response = await fetch(
        `https://api.github.com/repos/${this.repoOwner}/${this.repoName}/releases/latest`,
        {
          headers: {
            Accept: "application/vnd.github.v3+json",
          },
        }
      );

      if (!response.ok) {
        if (response.status === 404) {
          return {
            available: false,
            currentVersion: this.currentVersion,
            latestVersion: this.currentVersion,
            releaseNotes: "No releases found yet on GitHub.",
            publishedAt: new Date().toISOString(),
          };
        }
        throw new Error(`GitHub API error: ${response.statusText}`);
      }

      const data = await response.json();
      const tagName = data.tag_name || "v1.0.0";
      const cleanLatest = tagName.replace(/^v/, "");

      const isNewer = this.compareVersions(cleanLatest, this.currentVersion) > 0;

      // Find Windows EXE asset
      let downloadUrl = "";
      let fileSize = 0;
      if (Array.isArray(data.assets)) {
        const winAsset = data.assets.find(
          (a: any) =>
            a.name.endsWith(".exe") || a.name.includes("Setup") || a.name.includes("windows")
        );
        if (winAsset) {
          downloadUrl = winAsset.browser_download_url;
          fileSize = winAsset.size;
        }
      }

      return {
        available: isNewer,
        currentVersion: this.currentVersion,
        latestVersion: cleanLatest,
        releaseNotes: data.body || "Performance improvements and bug fixes.",
        publishedAt: data.published_at || new Date().toISOString(),
        downloadUrl,
        fileSize,
      };
    } catch (err: any) {
      console.warn("Failed to check GitHub releases:", err.message);
      // Fallback
      return {
        available: false,
        currentVersion: this.currentVersion,
        latestVersion: this.currentVersion,
        releaseNotes: "Could not connect to GitHub.",
        publishedAt: new Date().toISOString(),
      };
    }
  }

  /**
   * Trigger in-app native notification when update is available
   */
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
      // In web browser preview or development mode
      if ("Notification" in window && Notification.permission === "granted") {
        new Notification("🚀 PIXELDROP Update Available!", {
          body: `A new version (v${info.latestVersion}) is ready to install inside the app.`,
        });
      }
    }
  }

  /**
   * SemVer comparator: returns > 0 if v1 > v2, < 0 if v1 < v2, 0 if equal
   */
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
