{{flutter_js}}
{{flutter_build_config}}

// Service Worker（Flutterでは非推奨）は登録しない
_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();

    // 最初のフレームが描かれてから、読み込み中の表示を消す
    await new Promise((resolve) =>
      requestAnimationFrame(() => requestAnimationFrame(resolve)),
    );
    const loading = document.getElementById("loading");
    if (loading) {
      loading.classList.add("hidden");
      loading.addEventListener("transitionend", () => loading.remove());
      setTimeout(() => loading.remove(), 500);
    }
  },
});
