package EnsEMBL::Web::Component::Account::MemberGroups;

### Module to create list of groups that a user belongs to

use strict;
use warnings;
no warnings "uninitialized";
use base qw(EnsEMBL::Web::Component::Account);
use EnsEMBL::Web::Form;
use EnsEMBL::Web::RegObj;

sub _init {
  my $self = shift;
  $self->cacheable( 0 );
  $self->ajaxable(  0 );
}

sub caption {
  my $self = shift;
  return undef;
}

sub content {
  my $self = shift;
  my $html;

  my $user = $ENSEMBL_WEB_REGISTRY->get_user;
  my $sitename = $self->site_name;
  
  my @groups = $user->find_nonadmin_groups;

  if (@groups) {

    $html .= qq(<h3>Your subscribed groups</h3>);

    my $table = new EnsEMBL::Web::Document::SpreadSheet( [], [], {'margin' => '1em 0px'} );

    $table->add_columns(
        { 'key' => 'name',      'title' => 'Name',          'width' => '20%', 'align' => 'left' },
        { 'key' => 'desc',      'title' => 'Description',   'width' => '40%', 'align' => 'left' },
        { 'key' => 'admin',     'title' => 'Administrator', 'width' => '20%', 'align' => 'left' },
        { 'key' => 'details',   'title' => '',              'width' => '10%', 'align' => 'left' },
        { 'key' => 'leave',     'title' => '',              'width' => '10%', 'align' => 'left' },
    );

    foreach my $group (@groups) {
      my $row = {};

      $row->{'name'} = $group->name;
      $row->{'desc'} = $group->blurb || '&nbsp;';
      my $creator = EnsEMBL::Web::Data::User->new($group->created_by);
      $row->{'admin'} = $creator->name;
      if ($self->object->param('id') && $self->object->param('id') == $group->id) {
        $row->{'details'} = '<a href="/Account/MemberGroups?_referer='.CGI::escape($self->object->param('_referer')).'">Hide Details</a>';
      }
      else {
        $row->{'details'} = '<a href="/Account/MemberGroups?id='.$group->id.';_referer='.$self->object->param('_referer').'">Show Details</a>';
      }
      $row->{'leave'} = $self->delete_link('Membership', $group->id, 'Unsubscribe');
      $table->add_row($row);
    }
    $html .= $table->render;
  }
  else {
    $html .= qq(<p class="center">You are not subscribed to any $sitename groups.</p>);
  }

  return $html;
}

1;
