import IconButton from '@material-ui/core/IconButton';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
// import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction';
import ListItemText from '@material-ui/core/ListItemText';
import TapAndPlayIcon from '@material-ui/icons/TapAndPlay';
import * as React from 'react';
import './App.css';

import logo from './logo.svg';

interface IDevice {
  id: string
}

interface IDeviceListItemProps {
  device: IDevice
  ackDevice: (id: string) => void
}

interface IDeviceListProps {
  devices: IDevice[]
  ackDevice: (id: string) => void
}

class DeviceListItem extends React.Component<IDeviceListItemProps, object> {
  public render() {
    return (
      <ListItem>
        <ListItemText primary="test" />
        <ListItemSecondaryAction>
          <IconButton onTouchEnd={this.onAck}>
            <TapAndPlayIcon />
          </IconButton>
        </ListItemSecondaryAction>
      </ListItem>
    )
  }
  private onAck = () => {
    const {ackDevice, device} = this.props;
    ackDevice(device.id);
  }
}

class DeviceList extends React.Component<IDeviceListProps, object> {
  public render() {
    const {ackDevice, devices} = this.props;
    return (
      <List>
        {devices.map(
          (device, i) => <DeviceListItem
            device={device}
            key={i}
            ackDevice={ackDevice}
          />)}
      </List>
    )
  }
}

interface IAppState {
  devices: any
}

class App extends React.Component<{}, IAppState> {
  constructor(props: any) {
    super(props)
    this.state = {
      devices: []
    }
  }
  public componentDidMount() {
    fetch('http://localhost:8080/devices')
      .then(d => d.json())
      .then(d => this.setState({devices: d}))
  }
  public render() {
    const {devices} = this.state;
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to React</h1>
        </header>
        <DeviceList
          ackDevice={this.ackDevice}
          devices={devices} />
        <p className="App-intro">
          To get started, edit <code>src/App.tsx</code> and save to reload.
        </p>
      </div>
    );
  }
  private ackDevice(id: string) {
    fetch(`http://localhost:8080/devices/${id}/ack`)
      .then(d => d.text())
  }
}

export default App;
