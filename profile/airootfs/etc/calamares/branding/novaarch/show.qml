import QtQuick 2.7
import calamares.slideshow 1.0

Presentation {
  id: presentation

  Slide {
    title: qsTr("Welcome to NovaArch")
    text: qsTr("A lightweight Arch-based system tuned for gaming and daily use.")
    image: "/usr/share/pixmaps/novaarch.svg"
  }

  Slide {
    title: qsTr("Network-aware install flow")
    text: qsTr("The launcher validates connectivity before opening the installer so package and mirror setup are ready.")
    image: "/usr/share/pixmaps/novaarch.svg"
  }

  Slide {
    title: qsTr("Kernel tracks")
    text: qsTr("Default linux-zen for responsiveness with linux-lts fallback for stability and recovery.")
    image: "/usr/share/pixmaps/novaarch.svg"
  }
}
